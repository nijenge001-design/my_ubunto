# Laravel Application – Deployment & Operations Guide

**Version / Compatible with:** Laravel 11.x / 12.x, PHP 8.5
**Stack:** Ubuntu 26.04.1 LTS · Nginx (reverse proxy) → FrankenPHP v1.12.7 (Caddy v2.11.4) · MySQL 8.4.11 · Redis 8.0.5 · RabbitMQ 4.0.5 · Memcached 1.6.40 · Laravel Reverb
**Last updated:** 2026-09-26
**Owner / Maintainer:** _fill in_

---

## 1. Overview

- **What it is:** A production deployment of a Laravel application running on **FrankenPHP** (a Caddy-based, single-binary application server with built-in worker mode) sitting behind **Nginx** as a TLS-terminating reverse proxy. Persistence and background processing are handled by **MySQL** (relational data), **Redis** (cache, sessions, rate limiting), **Memcached** (secondary/object cache where used), **RabbitMQ** (durable queue backend), and **Laravel Reverb** (first-party WebSocket server for broadcasting).
- **Why we use it:** FrankenPHP's worker mode keeps the Laravel bootstrap (service container, routes, config) resident in memory between requests, avoiding PHP-FPM's per-request bootstrap cost. Nginx in front gives us battle-tested TLS termination, static asset serving, rate limiting, and a stable place to do host-based routing if we ever run multiple apps on one box. RabbitMQ gives durable, routable queues with dead-lettering, which is more robust for production job processing than the `database` or `redis` queue drivers. Reverb gives first-party WebSocket broadcasting without a third-party service (e.g. Pusher).
- **Role in our stack:** FrankenPHP is the application runtime; Nginx is the edge/ingress layer; MySQL is the system of record; Redis is the fast ephemeral store (cache, sessions, broadcast driver's presence channels, rate limiters); Memcached is an optional secondary object-cache tier; RabbitMQ decouples request/response from background work; Reverb handles real-time/WebSocket traffic in a dedicated process.
- **Key benefits:** Single-binary runtime with automatic HTTPS support (disabled here in favor of Nginx-managed TLS), HTTP/2 and HTTP/3 capability, low request overhead via worker mode, clean separation of concerns between web traffic, queue workers, and WebSocket traffic — each independently scalable and restartable.

> **Multi-app host:** this guide assumes the server may run more than one Laravel application side by side, not just the one being deployed right now. Every port, systemd unit, Nginx server block, database, and queue/cache namespace below is written so a **second, third, etc. app can be added later without colliding with an existing one** — see the "Multi-App Layout" callouts in §2, §3, §4, and Appendix A/B for the exact convention to follow each time a new app is onboarded.

> **Versions confirmed on the target host** (from `apt`/version-string output, 2026-09-26): Ubuntu 26.04.1 LTS · FrankenPHP v1.12.7 / Caddy v2.11.4 · PHP 8.5.11 (NTS, built by Ubuntu) · MySQL 8.4.11-0ubuntu0.26.04.1 · Redis 8.0.5 (jemalloc 5.3.0) · RabbitMQ 4.0.5 · Memcached 1.6.40. This guide's commands are written against these exact versions; re-verify against `composer.json` and the vendors' release notes if any of these drift.

---

## 2. Architecture & Position in the Stack

```
                              ┌────────────────────────────────────────┐
                              │              Ubuntu 26.04.1 LTS          │
                              │                                          │
[Internet] ──443/80──► Nginx  │  reverse proxy, TLS termination,        │
                       (edge) │  static files, gzip/br, rate-limit       │
                              │        │                    │           │
                              │        │ HTTP (unix socket   │ WS/HTTP    │
                              │        │ or 127.0.0.1:8080)  │ upgrade    │
                              │        ▼                    ▼           │
                              │   FrankenPHP            Laravel Reverb  │
                              │  (Laravel Octane        (artisan        │
                              │   worker mode)           reverb:start)  │
                              │        │                                │
                              │        ├──────────────┬─────────────┐   │
                              │        ▼              ▼             ▼   │
                              │     MySQL          Redis        Memcached│
                              │   (primary DB)   (cache/session/  (object│
                              │                   broadcaster     cache) │
                              │                   /rate limit)          │
                              │        │                                │
                              │        ▼                                │
                              │     RabbitMQ  ◄── queue:work workers     │
                              │   (durable queue backend, Supervisor-run)│
                              └────────────────────────────────────────┘
```

- **Request flow:** Browser → Nginx (443) → FrankenPHP worker (unix socket, recommended, or loopback TCP) → Laravel kernel → MySQL/Redis/Memcached as needed → response back through the same path.
- **Real-time flow:** Browser WebSocket → Nginx (443, `Upgrade`/`Connection` headers passed through) → Reverb process (its own port, e.g. 8080 internally) → Reverb publishes/subscribes; Laravel app pushes events to Reverb over its internal API when broadcasting.
- **Background work flow:** Laravel dispatches a job → RabbitMQ exchange/queue → one or more `queue:work` processes (managed by Supervisor or systemd) consume and execute jobs, with failures routed to a dead-letter queue.
- **Dependencies:**
  - FrankenPHP needs PHP extensions matching your `composer.json` (`pdo_mysql`, `redis` or `phpredis`, `memcached`, `amqp` or `bunny`/`php-amqplib` for RabbitMQ, `sockets`, `pcntl` for worker mode signal handling).
  - Reverb needs Redis if you run more than one Reverb process (Redis pub/sub keeps them in sync) — treat this as required in any multi-node setup.
  - RabbitMQ needs a queue driver package in Laravel (`vladimir-yuldashev/laravel-queue-rabbitmq` or similar — check your `composer.json`, the actual package used is app-specific).

> **Multi-App Layout:** MySQL, Redis, Memcached, and RabbitMQ are shared, host-level services — you do not run a separate instance per app. Isolation between apps happens one layer up:
> - **MySQL:** one schema + one least-privilege user per app (`app1_db`/`app1_user`, `app2_db`/`app2_user`, …), never a shared schema.
> - **Redis:** one numbered logical database per app (`REDIS_DB=0` for app1, `REDIS_DB=1` for app2, …, up to 15 by default) *or* a unique cache-key prefix per app (`CACHE_PREFIX` in `.env`) — pick one convention and apply it consistently so cache/session keys never collide.
> - **Memcached:** shares a single keyspace with no built-in namespacing — always set a distinct `CACHE_PREFIX` per app when using the `memcached` cache store.
> - **RabbitMQ:** one **virtual host** per app (`/app1`, `/app2`, …) with its own user scoped to that vhost only — this is the built-in RabbitMQ mechanism for exactly this kind of multi-tenant isolation.
> - **FrankenPHP/Octane and Reverb:** each app gets its own process bound to its own loopback port (see the port table in §3) and its own systemd unit instance, so one app's traffic spike or crash doesn't affect another's process.
> - **Filesystem:** each app lives under its own `/var/www/<app-name>/` with its own `.env`, own deploy user group membership, and its own log path.

---

## 3. Installation / Deployment

### Requirements

- **OS / Runtime:** Ubuntu 26.04.1 LTS (x86_64), fully patched (`apt update && apt upgrade`).
- **Minimum versions (target host is already running these exact builds):** PHP 8.5.11 (Laravel 11 requires 8.2+, Laravel 12 requires 8.3+ — confirm your app's `composer.json` supports 8.5), MySQL 8.4.11, Redis 8.0.5, RabbitMQ 4.0.5, Memcached 1.6.40, Node.js 20+ LTS (for asset builds, not runtime).
- **Resource recommendations (single-node starting point):**
  - App/web tier (Nginx + FrankenPHP): 2 vCPU / 4 GB RAM minimum for light-moderate traffic; scale workers with CPU count.
  - MySQL: 2 vCPU / 4 GB RAM minimum, more RAM improves InnoDB buffer pool hit ratio significantly.
  - Redis: 1 vCPU / 1–2 GB RAM (in-memory, size to working set).
  - RabbitMQ: 1–2 vCPU / 2 GB RAM baseline, more if queue depth/throughput is high.
  - Disk: SSD-backed, at least 20 GB for OS + app, size DB storage separately per data volume.

### Multi-App Layout — port and path convention

Reserve a block of ports per app up front so a second/third app can be added later without renumbering anything already running. A simple convention: base port `8000 + (app_index * 10)`.

| App | Directory | Octane/FrankenPHP port | Reverb port | MySQL DB / user | Redis DB index | RabbitMQ vhost |
|---|---|---|---|---|---|---|
| app1 (this deploy) | `/var/www/app1` | 127.0.0.1:8080 | 127.0.0.1:8081 | `app1_db` / `app1_user` | 0 | `/app1` |
| app2 (future) | `/var/www/app2` | 127.0.0.1:8090 | 127.0.0.1:8091 | `app2_db` / `app2_user` | 1 | `/app2` |
| app3 (future) | `/var/www/app3` | 127.0.0.1:8100 | 127.0.0.1:8101 | `app3_db` / `app3_user` | 2 | `/app3` |

Keep this table (or an equivalent) in your internal runbook and update it every time an app is onboarded — it is the single source of truth that prevents port/DB/vhost collisions on a shared host.

### Installation steps

```bash
# 1. Base system update and essentials
sudo apt update && sudo apt full-upgrade -y
sudo apt install -y curl wget gnupg2 ca-certificates lsb-release apt-transport-https \
  software-properties-common unzip git ufw

# 2. Create a dedicated, non-root deploy user
sudo adduser --disabled-password --gecos "" deploy
sudo usermod -aG www-data deploy

# 3. Install PHP CLI + extensions (needed for Composer, Artisan; FrankenPHP itself
#    embeds its own PHP 8.5 runtime, but Artisan/Composer on the host need a matching CLI build)
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update
sudo apt install -y php8.5-cli php8.5-common php8.5-mysql php8.5-mbstring php8.5-xml \
  php8.5-bcmath php8.5-curl php8.5-zip php8.5-redis php8.5-memcached php8.5-sockets \
  php8.5-gd php8.5-intl unzip
# Confirm host CLI and FrankenPHP-embedded PHP report the same major.minor (8.5) to avoid
# extension/ABI mismatches between `php artisan` (host CLI) and the FrankenPHP binary.

# 4. Install Composer
curl -sS https://getcomposer.org/installer -o composer-setup.php
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm composer-setup.php
composer --version

# 5. Install FrankenPHP (standalone binary; PHP is embedded in the binary itself)
curl -sLk https://raw.githubusercontent.com/php/frankenphp/main/install.sh | sh
sudo mv frankenphp /usr/local/bin/frankenphp
sudo setcap cap_net_bind_service=+ep /usr/local/bin/frankenphp
frankenphp version
# Expected on this host: FrankenPHP v1.12.7 PHP 8.5 Caddy v2.11.4 — if the installer pulls a
# different version, pin it explicitly (see frankenphp.dev/docs/installation for version-pinned installs).

# 6. Install Nginx
sudo apt install -y nginx
sudo systemctl enable --now nginx

# 7. Install MySQL Server
sudo apt install -y mysql-server
sudo mysql_secure_installation
sudo systemctl enable --now mysql

# Create an isolated schema + least-privilege user for THIS app only (repeat with a new
# schema/user per app added later — never share one schema across apps)
sudo mysql -e "
  CREATE DATABASE app1_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
  CREATE USER 'app1_user'@'127.0.0.1' IDENTIFIED BY '<strong-password>';
  GRANT ALL PRIVILEGES ON app1_db.* TO 'app1_user'@'127.0.0.1';
  FLUSH PRIVILEGES;
"

# 8. Install Redis (or Valkey — see licensing note in §4)
sudo apt install -y redis-server
sudo systemctl enable --now redis-server

# 9. Install Memcached
sudo apt install -y memcached
sudo systemctl enable --now memcached

# 10. Install RabbitMQ (official Team RabbitMQ repo — recommended over the Ubuntu archive package,
#     which typically lags behind upstream)
curl -1sLf "https://keys.rabbitmq.com/rabbitmq-release-signing-key.asc" | \
  sudo gpg --dearmor -o /usr/share/keyrings/rabbitmq.gpg
curl -1sLf "https://deb1.rabbitmq.com/rabbitmq-erlang/gpg.E495BB49CC4BBE5B.key" | \
  sudo gpg --dearmor -o /usr/share/keyrings/rabbitmq-erlang.gpg
echo "deb [signed-by=/usr/share/keyrings/rabbitmq-erlang.gpg] https://deb1.rabbitmq.com/rabbitmq-erlang/ubuntu noble main" | \
  sudo tee /etc/apt/sources.list.d/rabbitmq-erlang.list
echo "deb [signed-by=/usr/share/keyrings/rabbitmq.gpg] https://deb1.rabbitmq.com/rabbitmq-server/ubuntu noble main" | \
  sudo tee /etc/apt/sources.list.d/rabbitmq-server.list
sudo apt update
sudo apt install -y erlang-base erlang-crypto erlang-eldap erlang-ftp erlang-inets \
  erlang-mnesia erlang-os-mon erlang-parsetools erlang-runtime-tools erlang-snmp \
  erlang-ssl erlang-syntax-tools erlang-tftp erlang-tools erlang-xmerl rabbitmq-server
sudo systemctl enable --now rabbitmq-server
sudo rabbitmq-plugins enable rabbitmq_management   # optional, web UI on :15672

# Create an isolated vhost + user for THIS app only (repeat with a new vhost/user per app added later)
sudo rabbitmqctl add_vhost /app1
sudo rabbitmqctl add_user app1_user '<strong-password>'
sudo rabbitmqctl set_permissions -p /app1 app1_user ".*" ".*" ".*"
sudo rabbitmqctl set_user_tags app1_user management   # optional, lets this user see its vhost in the UI

# NOTE: confirm the correct RabbitMQ apt repo suite name for Ubuntu 26.04.1 LTS from
# rabbitmq.com/docs/install-debian before running this on a fresh host — the "noble" suite
# above may or may not be the one the repo publishes for 26.04 by the time you deploy.
# The version confirmed running on this host is RabbitMQ 4.0.5.

# 11. Deploy application code — note the app-specific directory; repeat this whole block
#     under /var/www/app2, /var/www/app3, etc. for each additional app on this host
sudo -u deploy git clone <your-repo-url> /var/www/app1
cd /var/www/app1
sudo -u deploy composer install --no-dev --optimize-autoloader
cp .env.example .env
sudo -u deploy php artisan key:generate
# In .env, set: DB_DATABASE=app1_db, DB_USERNAME=app1_user, REDIS_DB=0,
# RABBITMQ_VHOST=/app1, RABBITMQ_USER=app1_user, CACHE_PREFIX=app1_cache — per the port/path table above
sudo -u deploy php artisan migrate --force
sudo -u deploy php artisan storage:link
sudo -u deploy php artisan config:cache
sudo -u deploy php artisan route:cache
sudo -u deploy php artisan view:cache

# 12. Install Laravel Octane (FrankenPHP driver) and Reverb, if not already in composer.json
sudo -u deploy composer require laravel/octane laravel/reverb
sudo -u deploy php artisan octane:install --server=frankenphp
sudo -u deploy php artisan reverb:install
```

### Docker / Compose (if applicable)

If you prefer containers over bare-metal systemd services, an equivalent Compose layout looks like this. Adjust volumes, networks, and secrets management to your organization's standards.

```yaml
services:
  app:
    image: dunglas/frankenphp:1.12-php8.5
    volumes:
      - ./:/app
    environment:
      SERVER_NAME: ":8080"
      OCTANE_SERVER: frankenphp
    depends_on: [mysql, redis, memcached, rabbitmq]
    networks: [backend]

  reverb:
    image: dunglas/frankenphp:1.12-php8.5
    command: php artisan reverb:start --host=0.0.0.0 --port=8081
    volumes:
      - ./:/app
    depends_on: [redis]
    networks: [backend]

  queue-worker:
    image: dunglas/frankenphp:1.12-php8.5
    command: php artisan queue:work rabbitmq --tries=3 --backoff=5 --sleep=3
    volumes:
      - ./:/app
    depends_on: [rabbitmq, mysql]
    networks: [backend]
    deploy:
      replicas: 2

  mysql:
    image: mysql:8.4.11
    environment:
      MYSQL_DATABASE: app
      MYSQL_USER: app
      MYSQL_PASSWORD: ${DB_PASSWORD}
      MYSQL_RANDOM_ROOT_PASSWORD: "yes"
    volumes: [mysql_data:/var/lib/mysql]
    networks: [backend]

  redis:
    image: redis:8.0.5-alpine   # or a valkey/valkey image, see §4 licensing note
    volumes: [redis_data:/data]
    networks: [backend]

  memcached:
    image: memcached:1.6.40-alpine
    networks: [backend]

  rabbitmq:
    image: rabbitmq:4.0.5-management-alpine
    ports: ["15672:15672"]   # management UI, restrict/remove in production
    volumes: [rabbitmq_data:/var/lib/rabbitmq]
    networks: [backend]

  nginx:
    image: nginx:stable-alpine
    volumes:
      - ./docker/nginx.conf:/etc/nginx/conf.d/default.conf:ro
      - ./public:/app/public:ro
    ports: ["80:80", "443:443"]
    depends_on: [app, reverb]
    networks: [backend]

volumes:
  mysql_data:
  redis_data:
  rabbitmq_data:

networks:
  backend:
```

### Verification

```bash
# FrankenPHP / Octane running and serving requests
sudo -u deploy php artisan octane:status
curl -I http://127.0.0.1:8080/

# Nginx syntax and reload
sudo nginx -t && sudo systemctl reload nginx

# MySQL reachable and app can connect
mysql -u app -p -e "SELECT 1;"
sudo -u deploy php artisan tinker --execute="DB::connection()->getPdo();"

# Redis
redis-cli ping    # expect PONG

# Memcached
echo -e "stats\r\nquit\r" | nc 127.0.0.1 11211 | head -n 5

# RabbitMQ
sudo rabbitmqctl status
sudo rabbitmqctl list_queues

# Reverb
sudo -u deploy php artisan reverb:start --host=0.0.0.0 --port=8081 &
curl -I http://127.0.0.1:8081
```

---

## 4. Configuration

### Main config file(s)

- **Nginx:** `/etc/nginx/sites-available/app.conf` (symlinked into `sites-enabled`)
- **FrankenPHP/Octane:** `config/octane.php`, plus a `Caddyfile` if you run FrankenPHP standalone (`/var/www/app/Caddyfile`) instead of purely through `octane:start`
- **Laravel:** `/var/www/app/.env`, `config/*.php`
- **MySQL:** `/etc/mysql/mysql.conf.d/mysqld.cnf`
- **Redis:** `/etc/redis/redis.conf`
- **Memcached:** `/etc/memcached.conf`
- **RabbitMQ:** `/etc/rabbitmq/rabbitmq.conf`, definitions via `rabbitmqctl` or the management UI

| Setting | Value | Purpose |
|---|---|---|
| `OCTANE_SERVER` | `frankenphp` | Tells Octane which runtime driver to boot |
| `OCTANE_WORKERS` | `auto` or CPU-core count | Number of persistent worker processes |
| `OCTANE_MAX_REQUESTS` | `500`–`1000` | Recycle a worker after N requests to bound memory growth from leaks |
| `bind-address` (MySQL) | `127.0.0.1` | Restrict MySQL to loopback unless a dedicated DB host is used |
| `maxmemory-policy` (Redis) | `allkeys-lru` | Evict least-recently-used keys once memory limit is hit, appropriate for cache use |
| `-m` (Memcached) | e.g. `512` | Max memory in MB dedicated to the cache |
| `vm_memory_high_watermark` (RabbitMQ) | `0.4` | Fraction of system RAM before RabbitMQ throttles publishers |

### Environment variables / Laravel `.env`

```env
APP_NAME="Your App"
APP_ENV=production
APP_KEY=base64:...
APP_DEBUG=false
APP_URL=https://example.com

LOG_CHANNEL=stack
LOG_LEVEL=warning

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=app1_db
DB_USERNAME=app1_user
DB_PASSWORD=

CACHE_STORE=redis
CACHE_PREFIX=app1_cache
SESSION_DRIVER=redis
SESSION_LIFETIME=120

REDIS_CLIENT=phpredis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379
REDIS_DB=0

MEMCACHED_HOST=127.0.0.1
MEMCACHED_PORT=11211

QUEUE_CONNECTION=rabbitmq
RABBITMQ_HOST=127.0.0.1
RABBITMQ_PORT=5672
RABBITMQ_USER=app1_user
RABBITMQ_PASSWORD=
RABBITMQ_VHOST=/app1

BROADCAST_CONNECTION=reverb
REVERB_APP_ID=
REVERB_APP_KEY=
REVERB_APP_SECRET=
REVERB_HOST="127.0.0.1"
REVERB_PORT=8081
REVERB_SCHEME=http

VITE_REVERB_APP_KEY="${REVERB_APP_KEY}"
VITE_REVERB_HOST="example.com"
VITE_REVERB_PORT=443
VITE_REVERB_SCHEME=https

OCTANE_SERVER=frankenphp
OCTANE_HTTPS=false
```

### Recommended production settings

- **Security-related:** `APP_DEBUG=false` always; store secrets in `.env` with `chmod 640` owned by the deploy/service user; never commit `.env`; rotate `REVERB_APP_SECRET` and DB credentials on a schedule; bind MySQL/Redis/Memcached/RabbitMQ to `127.0.0.1` unless a dedicated internal network requires otherwise, and firewall the rest with UFW.
- **Performance-related:** enable OPcache with `validate_timestamps=0` in production (invalidate on deploy instead), tune `OCTANE_WORKERS` to CPU core count, set `OCTANE_MAX_REQUESTS` to recycle workers and avoid unbounded memory growth, size MySQL's `innodb_buffer_pool_size` to ~60–70% of available RAM on a dedicated DB host, set Redis `maxmemory` with an eviction policy appropriate to its use (cache vs. durable data), and give RabbitMQ appropriately sized queues (prefer quorum queues for durability in 4.x).
- **Logging:** ship logs to a centralized system (e.g. Loki, ELK, or a hosted APM) rather than relying solely on local files; set `LOG_LEVEL=warning` or `error` in production to reduce noise, with `debug` reserved for staging.

---

## 5. Usage & Common Operations

### Basic commands

```bash
# Octane/FrankenPHP (if managed by systemd, prefer systemctl over these directly)
php artisan octane:start --server=frankenphp --host=127.0.0.1 --port=8080
php artisan octane:reload     # graceful reload of workers after a deploy
php artisan octane:stop
php artisan octane:status

# Reverb
php artisan reverb:start --host=0.0.0.0 --port=8081
php artisan reverb:restart

# Queue workers
php artisan queue:work rabbitmq --queue=default,emails --tries=3 --backoff=5
php artisan queue:restart       # tell workers to gracefully finish current job then exit (Supervisor respawns)

# Service status via systemd (see §5 systemd units below)
sudo systemctl status octane
sudo systemctl status reverb
sudo systemctl status laravel-queue-worker@1
```

### How the application uses it

- **Laravel integration points:** `laravel/octane` with the `frankenphp` driver boots and keeps the application resident; `Cache`, `Session`, and rate limiters use the `redis` facade/driver; secondary or legacy cache paths may use `Cache::store('memcached')`; queued jobs use `ShouldQueue` and dispatch onto the `rabbitmq` connection defined in `config/queue.php`; real-time features use `broadcast()` / Echo channels backed by the `reverb` broadcaster in `config/broadcasting.php`.
- **Example code snippets:**

```php
// Dispatch a job onto RabbitMQ
ProcessOrder::dispatch($order)->onConnection('rabbitmq')->onQueue('orders');

// Cache with Redis
Cache::store('redis')->remember('dashboard:stats', now()->addMinutes(5), fn () =>
    Order::selectRaw('count(*) as total')->first()
);

// Broadcasting an event over Reverb
broadcast(new OrderShipped($order))->toOthers();
```

### Common day-to-day tasks

- **Clearing cache:** `php artisan cache:clear`, `php artisan config:clear`, `php artisan view:clear`, `php artisan route:clear` (re-run the `*:cache` equivalents afterward in production).
- **Restarting workers:** `php artisan queue:restart` (graceful, Supervisor respawns) or `sudo systemctl restart laravel-queue-worker@*` for a hard restart.
- **Checking connections:** `redis-cli ping`, `mysqladmin ping`, `sudo rabbitmqctl list_connections`, `sudo systemctl status reverb`.
- **Viewing logs:** `tail -f storage/logs/laravel.log`, `journalctl -u octane -f`, `journalctl -u reverb -f`, `journalctl -u laravel-queue-worker@1 -f`, `sudo rabbitmqctl list_queues name messages consumers`.

---

## 6. Monitoring & Health Checks

- **How to check health:** expose a lightweight `/up` health-check route (Laravel 11+ ships one by default) and point uptime monitoring at it; add a `/healthz` that also verifies DB/Redis/RabbitMQ connectivity for deeper checks if needed.
- **Key metrics to watch:**
  - FrankenPHP/Octane: worker count, requests/sec, memory per worker, restart frequency.
  - MySQL: connections used vs. `max_connections`, slow query log volume, replication lag if applicable, InnoDB buffer pool hit ratio.
  - Redis: memory usage vs. `maxmemory`, evictions/sec, hit/miss ratio, connected clients.
  - Memcached: `get_hits`/`get_misses`, evictions, current items.
  - RabbitMQ: queue depth (unacked + ready), consumer count per queue, publish/ack rates, memory/disk alarms.
  - Reverb: active connections, channel count, message throughput.
- **Logging location:** `storage/logs/laravel.log` (app), `journalctl` for systemd-managed services, `/var/log/nginx/{access,error}.log`, `/var/log/mysql/error.log`, RabbitMQ logs under `/var/log/rabbitmq/`.
- **Alerting recommendations:** alert on queue depth growing unbounded (workers falling behind), Redis approaching `maxmemory`, MySQL connections near the limit, RabbitMQ memory/disk alarm triggers, and Reverb process restarts or connection drops.

---

## 7. Security Considerations

- **Authentication / Authorization:** use Laravel's standard auth stack (Sanctum/Passport as appropriate) for the app; set strong, unique passwords for MySQL, Redis (`requirepass`), RabbitMQ, and the RabbitMQ management UI; disable the RabbitMQ `guest` user outside `localhost` (it's restricted to loopback by default — keep it that way).
- **Network exposure (ports, firewall):** only Nginx's 80/443 should be reachable from the public internet. Use UFW to restrict everything else to loopback or an internal VPC:

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
# MySQL (3306), Redis (6379), Memcached (11211), RabbitMQ (5672/15672), Reverb's internal
# port should NOT be opened publicly — they're reached over 127.0.0.1 or an internal network only.
```

- **Secrets management:** keep `.env` out of version control, restrict file permissions (`chmod 640`, owned by the app's service user), and prefer a secrets manager (Vault, AWS Secrets Manager, etc.) or your platform's encrypted environment store over plaintext files where available.
- **Recommended hardening steps:** keep Ubuntu, PHP, and all services patched via unattended-upgrades for security updates; run FrankenPHP/Octane and queue workers as a non-root `www-data`-group user; disable the RabbitMQ management plugin in production or restrict it behind an SSH tunnel/VPN; use TLS for the MySQL connection if the DB is not co-located; set `Content-Security-Policy` and standard security headers in Nginx; fail2ban on SSH and Nginx auth-failure patterns.

---

## 8. Troubleshooting

| Symptom | Possible Cause | Solution |
|---|---|---|
| 502 Bad Gateway from Nginx | FrankenPHP/Octane not running or wrong upstream socket/port | `systemctl status octane`; verify `proxy_pass` target matches the port/socket Octane is bound to |
| WebSocket connection fails / falls back to polling | Nginx not forwarding `Upgrade`/`Connection` headers, or Reverb port not reachable | Confirm the `location /app/` (or your Reverb path) block sets `proxy_set_header Upgrade $http_upgrade;` and `Connection "upgrade"`; check `journalctl -u reverb` |
| Stale config/routes after deploy | Cached config/routes from previous release still in effect | Re-run `php artisan config:cache && route:cache && view:cache` after every deploy, and `octane:reload` |
| Memory grows steadily on Octane workers | Static state leaking between requests (a common Octane pitfall) | Audit for singletons/static properties holding request-scoped data; lower `OCTANE_MAX_REQUESTS` as a stopgap |
| Jobs stuck in RabbitMQ, not processing | `queue:work` process died or Supervisor/systemd unit not running | Check `rabbitmqctl list_queues name messages consumers`; restart the worker unit; check `failed_jobs` table |
| `Redis::` calls throwing `Connection refused` | Redis bound to wrong interface or not running | `systemctl status redis-server`; confirm `REDIS_HOST`/`bind` in `redis.conf` match |
| MySQL `Too many connections` | Worker/connection pool sizing mismatch vs. `max_connections` | Tune `max_connections` on MySQL and/or reduce persistent connections from Octane workers |
| Reverb events not received by other Reverb nodes | Running multiple Reverb processes without a shared scaling driver | Configure `REVERB_SCALING_ENABLED=true` with Redis as documented in `config/reverb.php` |

**Useful debug commands:**
```bash
php artisan octane:status
php artisan queue:failed
sudo rabbitmqctl list_queues name messages_ready messages_unacknowledged consumers
redis-cli info memory
sudo journalctl -u octane -u reverb -u nginx --since "15 min ago"
sudo nginx -t
```

---

## 9. Performance Tuning (optional)

- **Recommended settings for production load:** enable OPcache (`opcache.validate_timestamps=0`, `opcache.jit=tracing` where compatible with your PHP version); set `OCTANE_WORKERS` to match available CPU cores; batch/queue anything that doesn't need a synchronous response; use Redis for sessions/cache instead of the database driver to keep MySQL free for transactional work; enable RabbitMQ quorum queues for critical job types needing durability guarantees.
- **Scaling considerations:** FrankenPHP/Octane and queue workers scale horizontally behind a load balancer or additional queue-worker replicas; MySQL scales vertically first, then via read replicas for read-heavy workloads; Redis can move to a dedicated instance/cluster once cache traffic grows; RabbitMQ can be clustered for HA; run more than one Reverb node only once `REVERB_SCALING_ENABLED` + Redis pub/sub is configured, otherwise clients on different nodes won't see each other's events.

---

## 10. References

- Official documentation:
  - Laravel: https://laravel.com/docs
  - Laravel Octane: https://laravel.com/docs/octane
  - Laravel Reverb: https://laravel.com/docs/reverb
  - FrankenPHP: https://frankenphp.dev
  - Nginx: https://nginx.org/en/docs/
  - MySQL: https://dev.mysql.com/doc/
  - Redis: https://redis.io/docs/latest/ — background on licensing: Redis moved to RSALv2/SSPLv1 with 7.4 (2024), then added AGPLv3 back as of Redis 8.0 (May 2025), so the 8.0.5 build on this host is OSI-approved open source again (tri-licensed: AGPLv3, RSALv2, SSPLv1). The community fork **Valkey** — https://valkey.io — remains BSD-licensed as an alternative if your organization standardized on it during the RSAL period.
  - RabbitMQ: https://www.rabbitmq.com/docs
  - Memcached: https://memcached.org
- Internal runbooks / related guides: _link your incident runbooks, on-call rotation, and CI/CD pipeline docs here_
- Changelog / version notes: _track stack version bumps here as they happen_

---

## Appendix A — Sample Nginx site config (multi-app pattern)

One config file **per app** under `/etc/nginx/sites-available/`, each with its own upstream block, its own `server_name`, and its own certificate — pointed at that app's dedicated ports from the table in §3. Below are two apps side by side to show the pattern; add a third the same way.

```nginx
# /etc/nginx/sites-available/app1.conf
upstream frankenphp_app1 {
    server 127.0.0.1:8080;
    keepalive 32;
}

server {
    listen 80;
    server_name app1.example.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name app1.example.com;

    ssl_certificate     /etc/letsencrypt/live/app1.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/app1.example.com/privkey.pem;

    root /var/www/app1/public;
    index index.php;

    client_max_body_size 20m;
    access_log /var/log/nginx/app1-access.log;
    error_log  /var/log/nginx/app1-error.log;

    location / {
        try_files $uri @octane_app1;
    }

    location @octane_app1 {
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header Scheme $scheme;
        proxy_set_header SERVER_PORT $server_port;
        proxy_set_header REMOTE_ADDR $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_pass http://frankenphp_app1;
    }

    # Laravel Reverb — WebSocket upgrade, app1's dedicated Reverb port
    location /app/ {
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 86400;
        proxy_pass http://127.0.0.1:8081;
    }
}
```

```nginx
# /etc/nginx/sites-available/app2.conf — same pattern, different domain, ports, and paths
upstream frankenphp_app2 {
    server 127.0.0.1:8090;
    keepalive 32;
}

server {
    listen 80;
    server_name app2.example.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name app2.example.com;

    ssl_certificate     /etc/letsencrypt/live/app2.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/app2.example.com/privkey.pem;

    root /var/www/app2/public;
    index index.php;

    client_max_body_size 20m;
    access_log /var/log/nginx/app2-access.log;
    error_log  /var/log/nginx/app2-error.log;

    location / {
        try_files $uri @octane_app2;
    }

    location @octane_app2 {
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header Scheme $scheme;
        proxy_set_header SERVER_PORT $server_port;
        proxy_set_header REMOTE_ADDR $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_pass http://frankenphp_app2;
    }

    location /app/ {
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 86400;
        proxy_pass http://127.0.0.1:8091;
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/app1.conf /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/app2.conf /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

## Appendix B — Sample systemd units (multi-app pattern)

Give every app **its own named unit files** (not a shared, generic `octane.service`) so apps can be started, stopped, and restarted independently — one app's redeploy or crash never touches another's process. The naming convention below (`-app1`, `-app2`, …) mirrors the port/path table in §3; copy the block for each additional app, swapping the app name, `WorkingDirectory`, and port.

```ini
# /etc/systemd/system/octane-app1.service
[Unit]
Description=Laravel Octane (FrankenPHP) - app1
After=network.target mysql.service redis-server.service

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/var/www/app1
ExecStart=/usr/bin/php artisan octane:start --server=frankenphp --host=127.0.0.1 --port=8080
ExecReload=/usr/bin/php artisan octane:reload
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

```ini
# /etc/systemd/system/reverb-app1.service
[Unit]
Description=Laravel Reverb WebSocket server - app1
After=network.target redis-server.service

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/var/www/app1
ExecStart=/usr/bin/php artisan reverb:start --host=0.0.0.0 --port=8081
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

```ini
# /etc/systemd/system/laravel-queue-worker-app1@.service
# Templated ONLY over worker replica number, scoped to app1 by WorkingDirectory.
# Enable N replicas: systemctl enable --now laravel-queue-worker-app1@{1..4}
[Unit]
Description=Laravel Queue Worker (RabbitMQ) - app1 #%i
After=network.target rabbitmq-server.service mysql.service

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/var/www/app1
ExecStart=/usr/bin/php artisan queue:work rabbitmq --queue=default --tries=3 --backoff=5 --sleep=3 --max-time=3600
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now octane-app1 reverb-app1
sudo systemctl enable --now laravel-queue-worker-app1@{1..4}
```

**Onboarding app2 (or any additional app)** later is the same three files with `app1` swapped for `app2`, `WorkingDirectory=/var/www/app2`, port `8090`/`8091` (per the table in §3), and its own set of queue-worker instances (`laravel-queue-worker-app2@{1..4}`) — no changes needed to app1's units.

## Appendix C — Scheduled Tasks (Cron / Laravel Scheduler)

If an application defines scheduled jobs (`app/Console/Kernel.php` on Laravel <11, or `routes/console.php`'s `Schedule::` calls on Laravel 11+), the scheduler itself does nothing on its own — something on the host has to invoke `php artisan schedule:run` on a regular cadence, **once per app**. On a multi-app host each app gets its own cron line or its own timer unit, exactly like each app gets its own Octane/Reverb unit above — never point one scheduler entry at more than one app's directory.

### Option 1 — Classic cron (simplest, works everywhere)

```bash
sudo crontab -u www-data -e
```

Add one line per app:

```cron
* * * * * cd /var/www/app1 && php artisan schedule:run >> /dev/null 2>&1
* * * * * cd /var/www/app2 && php artisan schedule:run >> /dev/null 2>&1
```

This runs every minute per app; the scheduler itself decides which registered tasks are actually due, so sub-minute precision isn't needed here.

### Option 2 — systemd timer (preferred if you want scheduler runs visible in `journalctl` alongside your other services)

```ini
# /etc/systemd/system/laravel-schedule-app1.service
[Unit]
Description=Laravel Scheduler run - app1
After=network.target mysql.service

[Service]
Type=oneshot
User=www-data
Group=www-data
WorkingDirectory=/var/www/app1
ExecStart=/usr/bin/php artisan schedule:run
```

```ini
# /etc/systemd/system/laravel-schedule-app1.timer
[Unit]
Description=Run app1's Laravel scheduler every minute

[Timer]
OnCalendar=*-*-* *:*:00
AccuracySec=1sec
Persistent=true

[Install]
WantedBy=timers.target
```

Copy both files with `-app2`, `-app3`, etc. and the matching `WorkingDirectory` for each additional app.

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now laravel-schedule-app1.timer
systemctl list-timers 'laravel-schedule-*'     # confirm next scheduled run for every app
journalctl -u laravel-schedule-app1.service -f # watch app1's scheduler runs and any task output
```

**Notes:**
- Never run more than one scheduler invoker **for the same app** (don't enable both the cron entry and the systemd timer for `app1` at once) — running `schedule:run` twice per minute from two sources will double-fire overlapping tasks. Different apps having their own entries is fine and expected.
- For long-running or overlap-prone tasks, use `->withoutOverlapping()` on the scheduled command definition rather than trying to solve overlap at the OS level.
- If tasks need to run on a specific node in a multi-node deployment (to avoid double-execution across app servers), use `->onOneServer()`, which requires a shared cache driver — Redis, already configured here via `CACHE_STORE=redis`, satisfies this. Remember each app already has its own `REDIS_DB` index (§3 table), so this coordination stays scoped to that one app.
- Check scheduler health the same way as other services: `php artisan schedule:list` (run from inside each app's directory) shows every registered task and its next due time.

---

## Appendix D — Deployment Checklist

Use this for every new app onboarded to the host, and re-run the relevant subset on every release of an existing app.

### One-time host setup (do once per server, not per app)
- [ ] Ubuntu updated and unattended-upgrades enabled
- [ ] `deploy` user created, added to `www-data` group
- [ ] PHP CLI, Composer, and FrankenPHP binary installed; `php --version` and `frankenphp version` confirmed
- [ ] Nginx, MySQL, Redis, Memcached, RabbitMQ installed and enabled at boot
- [ ] UFW enabled: only SSH, 80, 443 open publicly; DB/cache/queue ports confirmed loopback-only
- [ ] RabbitMQ management UI restricted or tunneled, not exposed publicly
- [ ] Central log shipping / uptime monitoring pointed at this host

### New app onboarding (do once per app)
- [ ] Next free port pair reserved and recorded in the port/path table (§3): Octane port, Reverb port
- [ ] `/var/www/<app>` created; repo cloned as the `deploy` user
- [ ] Dedicated MySQL schema + least-privilege user created for this app only
- [ ] Dedicated RabbitMQ vhost + user created for this app only
- [ ] Dedicated Redis DB index (or unique `CACHE_PREFIX`) assigned and not already in use by another app
- [ ] `.env` populated with this app's DB, Redis, Memcached, RabbitMQ, and Reverb values (no values copy-pasted from another app's `.env`)
- [ ] `APP_KEY` generated fresh for this app (`php artisan key:generate`) — never reused across apps
- [ ] `composer install --no-dev --optimize-autoloader` run
- [ ] Laravel Octane + Reverb installed (`octane:install --server=frankenphp`, `reverb:install`) if not already vendored
- [ ] Migrations run (`migrate --force`), `storage:link` run
- [ ] Config/route/view caches built (`config:cache`, `route:cache`, `view:cache`)
- [ ] Dedicated systemd units created and enabled: `octane-<app>`, `reverb-<app>`, `laravel-queue-worker-<app>@{N}`
- [ ] Scheduler entry added for this app only (cron line or `laravel-schedule-<app>.timer`) — confirmed no duplicate entry exists
- [ ] Dedicated Nginx server block created (`<app>.conf`), symlinked into `sites-enabled`, TLS certificate issued for its domain
- [ ] `nginx -t` passes; `systemctl reload nginx`
- [ ] End-to-end smoke test: HTTP request through Nginx reaches the app, WebSocket connects through Reverb, a test job runs through this app's RabbitMQ vhost, a scheduled command's `schedule:list` entry appears
- [ ] Firewall/UFW re-checked — no new ports accidentally opened publicly for this app

### Every release of an existing app
- [ ] Pull latest code as the `deploy` user; review `.env.example` diff for any new required variables
- [ ] `composer install --no-dev --optimize-autoloader`
- [ ] `migrate --force` (review any destructive migrations first, and back up the schema beforehand for anything non-trivial)
- [ ] `config:cache`, `route:cache`, `view:cache` rebuilt (clear-then-cache if any got stale)
- [ ] `php artisan octane:reload` (graceful worker reload — avoids a hard restart / dropped in-flight requests)
- [ ] `php artisan queue:restart` (workers finish current job, Supervisor/systemd respawns fresh code)
- [ ] `php artisan reverb:restart` if the Reverb-related config or broadcast events changed
- [ ] Confirm `systemctl status octane-<app> reverb-<app> laravel-queue-worker-<app>@*` all show active/running post-deploy
- [ ] Tail `storage/logs/laravel.log` and relevant `journalctl -u` output for a few minutes post-deploy to catch immediate errors
- [ ] Confirm this app's changes didn't touch another app's directory, unit files, DB, or `.env` — multi-app hosts make cross-app copy/paste mistakes the most common failure mode

---

## Appendix E — Getting the Application Onto the Server (three source methods)

Step 11 in §3 assumed a plain `git clone`. In practice the source for a given app might arrive as a GitHub repo, a pre-built zip archive, or a direct SSH push from a build machine/CI runner. All three land in the same place — `/var/www/<app>` — so everything else in this guide (`.env` values, systemd units, Nginx config, the checklist above) is unchanged regardless of which method delivered the code.

### Method 1 — Clone from GitHub

Public repos need nothing special. Private repos should use a **deploy key** scoped read-only to that one repo, rather than a personal SSH key, so a compromised server can't be used to reach other repos.

```bash
# Public repo
sudo -u deploy git clone https://github.com/<org>/<repo>.git /var/www/app1
```

```bash
# Private repo — generate a dedicated, passphrase-less deploy key so unattended deploys work
sudo -u deploy ssh-keygen -t ed25519 -f /home/deploy/.ssh/app1_deploy_key -N ""
sudo -u deploy cat /home/deploy/.ssh/app1_deploy_key.pub
# → paste this public key into: GitHub repo → Settings → Deploy keys → Add deploy key (read-only, no write access)

# Scope that key to this repo only, under an alias host so other repos/keys are unaffected
sudo -u deploy tee -a /home/deploy/.ssh/config > /dev/null <<'EOF'
Host github.com-app1
    HostName github.com
    User git
    IdentityFile /home/deploy/.ssh/app1_deploy_key
    IdentitiesOnly yes
EOF
sudo -u deploy chmod 600 /home/deploy/.ssh/config

sudo -u deploy git clone git@github.com-app1:<org>/<repo>.git /var/www/app1
```

Redeploys afterward are just a pull:
```bash
cd /var/www/app1 && sudo -u deploy git pull origin main
```

### Method 2 — From a zip file

Good for apps shipped as a pre-built release artifact rather than tracked directly in git on this server (e.g. a CI pipeline outputs a zip, or you're migrating an app off another host).

```bash
# From your local machine / build pipeline, upload the archive
scp app1-release.zip deploy@<server-ip>:/tmp/

# On the server: extract into place and fix ownership/permissions
sudo mkdir -p /var/www/app1
sudo unzip /tmp/app1-release.zip -d /var/www/app1
sudo chown -R deploy:www-data /var/www/app1
sudo find /var/www/app1 -type d -exec chmod 750 {} \;
sudo find /var/www/app1 -type f -exec chmod 640 {} \;
sudo chmod -R ug+w /var/www/app1/storage /var/www/app1/bootstrap/cache
rm /tmp/app1-release.zip
```

For a repeat deploy, avoid unzipping over a live app (see the zero-downtime note below) — extract each new zip into its own release directory instead.

### Method 3 — Direct push over SSH (rsync, no GitHub or zip step)

Fastest option for a build machine or CI runner pushing an already-built app straight to the server, skipping both GitHub and manual archive handling.

```bash
# From the build machine / CI runner
rsync -avz --delete \
  --exclude='.env' --exclude='storage/' --exclude='.git/' \
  ./ deploy@<server-ip>:/var/www/app1/
```

`--exclude='.env'` and `--exclude='storage/'` are important on every sync — they protect the server's live secrets and any user-uploaded files from being wiped by whatever happens to be (or not be) in the source tree.

### After the code lands — same for all three methods

```bash
cd /var/www/app1
sudo -u deploy composer install --no-dev --optimize-autoloader
# first deploy only: cp .env.example .env && php artisan key:generate, then fill in this app's
# DB/Redis/RabbitMQ/Reverb values per the port/path table in §3
sudo -u deploy php artisan migrate --force
sudo -u deploy php artisan storage:link          # first deploy only
sudo -u deploy php artisan config:cache
sudo -u deploy php artisan route:cache
sudo -u deploy php artisan view:cache
sudo -u deploy php artisan octane:reload         # graceful reload, not a hard restart
sudo -u deploy php artisan queue:restart
```

### Zero-downtime note (applies to all three methods)

For anything beyond a low-traffic app, deploy into a timestamped release directory and atomically flip a symlink rather than overwriting the live code in place:

```
/var/www/app1/releases/2026-09-30-1200/        ← new code lands here, fully built and cached
/var/www/app1/current -> releases/2026-09-30-1200/   ← symlink flipped only once the new release is ready
```

Point Nginx's `root` and each app's systemd units' `WorkingDirectory` at `/var/www/app1/current` instead of the app directory directly — a bad deploy then becomes "flip the symlink back," not a rebuild, and in-flight requests against the old release finish cleanly before Octane/Reverb reload onto the new one.
