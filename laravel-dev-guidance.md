# Laravel 13+ Local Development Guidance

**Version / Compatible with:** Laravel 13.x (released March 17, 2026), PHP 8.3–8.5
**Companion to:** `laravel-deployment-guide.md` (Ubuntu 26.04.1 LTS · Nginx → FrankenPHP · MySQL · Redis · RabbitMQ · Memcached · Reverb)
**Last updated:** 2026-09-26
**Owner / Maintainer:** _fill in_

---

## 1. Overview

- **What this is:** the local development counterpart to the production deployment guide. The goal is **dev/prod parity** — the same runtime (FrankenPHP), the same data stores (MySQL, Redis, Memcached), the same queue backend (RabbitMQ), and the same broadcaster (Reverb) locally as on the server, so "works on my machine" failures caused by stack drift don't happen.
- **Why it matters:** Laravel 13 requires **PHP 8.3 as a hard minimum** (dropping 8.1/8.2 support) and supports up to 8.3–8.5 depending on your other dependencies — matching the production host's PHP 8.5.11 locally means you catch version-specific issues (deprecations, JIT behavior, attribute syntax) before they reach the server, not after.
- **Two supported setups**, described below — pick one per machine, don't mix:
  1. **Docker Compose** (recommended) — every service runs at the exact versions pinned in the deployment guide, isolated per project, torn down with one command.
  2. **Native install** — services installed directly on the developer's OS. Faster iteration for some workflows, but requires the developer to manually keep versions aligned with production.

---

## 2. Prerequisites

| Tool | Version | Notes |
|---|---|---|
| PHP | 8.3–8.5 (match prod: 8.5.11) | Laravel 13 refuses to boot on 8.1/8.2 |
| Composer | 2.7+ | |
| Node.js | 20+ LTS | for Vite/asset builds only, not a runtime dependency |
| Git | any recent version | |
| Docker + Docker Compose | latest stable | only needed for the Docker Compose setup |
| An editor with PHP tooling | PhpStorm, VS Code + Intelephense, or similar | attribute-based config (see §9) benefits from an editor that understands PHP 8 Attributes |

Confirm before starting:
```bash
php -v            # expect 8.3.x, 8.4.x, or 8.5.x
composer -V
node -v
docker compose version
```

> **Windows developers:** see Appendix A for the Docker vs WSL2 decision before setting anything up — the short version is Docker Desktop with the WSL2 backend, with the project living inside the WSL2 filesystem, not `C:\...`.

---

## 3. Getting the Project — three methods (mirrors the deployment guide)

The deployment guide's Appendix E covers GitHub, zip, and SSH delivery for the **server**; locally, GitHub clone is the default for day-to-day development, with the other two as fallbacks.

```bash
# Standard method — clone via GitHub (SSH, using your personal key, not the server's deploy key)
git clone git@github.com:<org>/<repo>.git
cd <repo>

# Fallback — a teammate hands you a zip export (e.g. no repo access yet)
unzip project-export.zip -d ./<repo> && cd <repo>

# Fallback — pulling a colleague's in-progress branch directly via SSH/rsync (rare; prefer git branches)
rsync -avz --exclude='.env' --exclude='vendor/' --exclude='node_modules/' \
  teammate@their-machine:/path/to/project/ ./<repo>/
```

---

## 4. Docker Compose setup (recommended)

This mirrors the production stack's exact versions from the deployment guide: **FrankenPHP (PHP 8.5), MySQL 8.4, Redis 8.0, Memcached 1.6, RabbitMQ 4.0, Reverb.**

```yaml
# docker-compose.yml
services:
  app:
    image: dunglas/frankenphp:1.12-php8.5
    working_dir: /app
    volumes:
      - ./:/app
    environment:
      SERVER_NAME: ":80"
      OCTANE_SERVER: frankenphp
      APP_ENV: local
      APP_DEBUG: "true"
    ports:
      - "8000:80"          # http://localhost:8000
    depends_on: [mysql, redis, memcached, rabbitmq]

  vite:
    image: node:20-alpine
    working_dir: /app
    volumes:
      - ./:/app
    command: sh -c "npm install && npm run dev -- --host 0.0.0.0"
    ports:
      - "5173:5173"         # Vite dev server, HMR

  reverb:
    image: dunglas/frankenphp:1.12-php8.5
    working_dir: /app
    volumes:
      - ./:/app
    command: php artisan reverb:start --host=0.0.0.0 --port=8081
    ports:
      - "8081:8081"
    depends_on: [redis]

  queue:
    image: dunglas/frankenphp:1.12-php8.5
    working_dir: /app
    volumes:
      - ./:/app
    command: php artisan queue:listen rabbitmq --tries=1
    depends_on: [rabbitmq, mysql]

  scheduler:
    image: dunglas/frankenphp:1.12-php8.5
    working_dir: /app
    volumes:
      - ./:/app
    command: php artisan schedule:work    # dev-only convenience; prod uses cron/systemd timer, not this
    depends_on: [mysql]

  mysql:
    image: mysql:8.4.11
    environment:
      MYSQL_DATABASE: app_dev
      MYSQL_USER: app
      MYSQL_PASSWORD: secret
      MYSQL_ROOT_PASSWORD: root_secret
    volumes: [mysql_data:/var/lib/mysql]
    ports:
      - "3306:3306"

  redis:
    image: redis:8.0.5-alpine
    ports:
      - "6379:6379"

  memcached:
    image: memcached:1.6.40-alpine
    ports:
      - "11211:11211"

  rabbitmq:
    image: rabbitmq:4.0.5-management-alpine
    ports:
      - "5672:5672"
      - "15672:15672"       # management UI: http://localhost:15672 (guest/guest, local only)

  mailpit:
    image: axllent/mailpit
    ports:
      - "8025:8025"         # catch-all mail UI for local dev — never a real mailer in prod
      - "1025:1025"

volumes:
  mysql_data:
```

```bash
docker compose up -d
docker compose exec app composer install
docker compose exec app cp .env.example .env
docker compose exec app php artisan key:generate
docker compose exec app php artisan migrate --seed
```

Local `.env` values point at the Compose service names, not `127.0.0.1`, since each service is its own container reachable by hostname on the Compose network:

```env
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=mysql
DB_HOST=mysql
DB_DATABASE=app_dev
DB_USERNAME=app
DB_PASSWORD=secret

CACHE_STORE=redis
SESSION_DRIVER=redis
REDIS_HOST=redis
REDIS_DB=0

MEMCACHED_HOST=memcached

QUEUE_CONNECTION=rabbitmq
RABBITMQ_HOST=rabbitmq
RABBITMQ_VHOST=/

BROADCAST_CONNECTION=reverb
REVERB_HOST=reverb
REVERB_PORT=8081
REVERB_SCHEME=http
VITE_REVERB_HOST=localhost
VITE_REVERB_PORT=8081
VITE_REVERB_SCHEME=http

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
```

---

## 5. Native install setup (alternative)

If a developer prefers running services directly on their OS instead of Docker, keep versions aligned with the deployment guide rather than "whatever the package manager gives you":

```bash
# macOS (Homebrew) — pin to matching majors where the formula allows it
brew install php@8.5 composer mysql@8.4 redis rabbitmq

# Ubuntu/Debian dev machine — same PPA/repo steps as the deployment guide §3, just without
# the systemd unit files (use `php artisan serve` / `octane:start` in a terminal instead)
```

> **Windows developers:** these are the same commands to run **inside a WSL2 Ubuntu distro** if going the native-install route instead of Docker — see Appendix A for when that's the better choice, and the filesystem-location caveat that applies either way.

```bash
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed

# Run everything in separate terminals (or a process manager — see §6)
php artisan octane:start --server=frankenphp --watch
php artisan reverb:start
php artisan queue:listen rabbitmq
php artisan schedule:work
npm run dev
```

`.env` for native install points at `127.0.0.1` for each service instead of Compose hostnames, otherwise identical to §4's example.

---

## 6. Running everything at once

For either setup, `composer.json`'s `dev` script (Laravel's default scaffold) runs Octane/serve, the queue listener, the scheduler, and Vite concurrently in one terminal — convenient for solo work, though the Docker Compose services in §4 give clearer separated logs per process, which is usually preferable once RabbitMQ/Reverb are involved:

```bash
composer run dev
```

---

## 7. Testing

Laravel 13 ships with Pest as the default testing scaffold.

```bash
php artisan test              # or: ./vendor/bin/pest
php artisan test --coverage   # requires Xdebug or PCOV
php artisan test --parallel
```

- **Database:** feature tests default to an in-memory SQLite connection (fast, isolated) unless the app's test suite specifically needs MySQL-only behavior (JSON column functions, specific collation behavior) — in which case point `phpunit.xml`'s test DB connection at a dedicated `app_test` MySQL schema, never the dev schema.
- **Queues:** use `Queue::fake()` in tests rather than hitting real RabbitMQ; reserve an actual RabbitMQ-backed test for a small number of integration tests that specifically verify the queue driver wiring.
- **Broadcasting:** use `Event::fake()` / `Http::fake()` for Reverb-dependent tests; don't stand up a real Reverb connection in the test suite.
- **Mail:** Mailpit (in the Compose file above) catches real outgoing mail during manual testing; automated tests should still use `Mail::fake()`.

---

## 8. Coding standards & static analysis

```bash
composer require laravel/pint --dev
composer require larastan/larastan --dev

./vendor/bin/pint                 # auto-fix formatting to Laravel's style
./vendor/bin/pint --test          # check only, for CI
./vendor/bin/phpstan analyse      # static analysis (configure level in phpstan.neon)
```

Add a pre-commit hook (e.g. via `captainhook/captainhook` or a simple `.git/hooks/pre-commit` shell script) so `pint --test` and `phpstan analyse` run before every commit, catching style/type issues before they reach a PR.

---

## 9. Laravel 13-specific notes

- **PHP 8.3 is now the hard floor.** If a teammate's machine is still on 8.1/8.2, `composer install` will refuse to resolve dependencies — direct them to upgrade PHP first, before touching `composer.json`.
- **PHP Attributes as an alternative to property-based config** are now supported across 15+ locations (models, jobs, console commands, and more) — e.g. `#[Table('users')]`, `#[Hidden(['password'])]`, `#[Fillable(['name','email'])]` instead of the equivalent `protected $table`, `$hidden`, `$fillable` properties. This is optional and fully backward compatible; agree as a team whether new code should adopt the attribute style or keep the property style for consistency with existing models.
- **First-party Laravel AI SDK** ships in 13 for text generation, tool-calling agents, embeddings, and vector-store integration — if the app uses this, keep any provider API keys in `.env` only (never committed), same as any other secret.
- **First-party JSON:API resources** are available if the app's API needs to comply with the JSON:API spec — evaluate against the app's existing API resource conventions before adopting wholesale.

---

## 10. Environment Parity Matrix

Cross-reference with the deployment guide's §3 port/path table — this is the same versions, mapped to local equivalents:

| Component | Production (per deployment guide) | Local (Docker Compose) |
|---|---|---|
| PHP | 8.5.11 | 8.5 (via `dunglas/frankenphp:1.12-php8.5`) |
| FrankenPHP | v1.12.7 / Caddy v2.11.4 | same image tag |
| MySQL | 8.4.11, dedicated schema/user per app | 8.4.11, `app_dev` schema |
| Redis | 8.0.5, one DB index per app | 8.0.5, DB index 0 |
| Memcached | 1.6.40 | 1.6.40 |
| RabbitMQ | 4.0.5, one vhost per app | 4.0.5, default `/` vhost (single-project local, no isolation needed) |
| Reverb | app-specific port (e.g. 8081) | 8081 |
| Scheduler | cron / systemd timer, once per app | `schedule:work` (dev convenience only — never use `schedule:work` in production) |
| Mail | real SMTP provider | Mailpit catch-all |

---

## 11. Debugging

- **Xdebug:** install via `pecl install xdebug` (native) or add `RUN install-php-extensions xdebug` to a custom FrankenPHP dev image (Compose setup); set `xdebug.mode=debug`, `xdebug.client_host=host.docker.internal` when running inside Docker, and configure your editor's debug listener on port 9003.
- **Laravel Telescope** (`composer require laravel/telescope --dev`) gives request/query/queue/Reverb-event visibility in local dev — install it as a dev dependency only, never enable it in production.
- **Laravel Pulse** can be run locally too if the team wants a preview of the same metrics that would be monitored in production (see the deployment guide's §6 Monitoring).

---

## 12. Common commands cheat-sheet

```bash
# Fresh clone bootstrap
composer install && cp .env.example .env && php artisan key:generate && php artisan migrate --seed

# Day-to-day
composer run dev                      # everything at once (Octane, queue, scheduler, Vite)
php artisan tinker                    # REPL against the app
php artisan make:model Post -mfs      # model + migration + factory + seeder
php artisan route:list

# Reset local DB
php artisan migrate:fresh --seed

# Rebuild containers after a Dockerfile/Compose change
docker compose down && docker compose up -d --build
```

---

## 13. Troubleshooting

| Symptom | Possible Cause | Solution |
|---|---|---|
| `composer install` fails on PHP version constraint | Local PHP is 8.1/8.2, Laravel 13 requires 8.3+ | Upgrade local PHP before touching dependencies |
| Reverb events not received in browser during local dev | Vite env vars pointing at wrong host/port, or Reverb container not up | Confirm `VITE_REVERB_*` matches the exposed port (8081) and `docker compose ps` shows `reverb` running |
| Queue jobs never processed locally | No `queue:listen`/`queue` container running, or `QUEUE_CONNECTION` still `sync` | Start the queue worker/container; confirm `.env` matches §4 |
| MySQL connection refused from `app` container | `DB_HOST` set to `127.0.0.1` instead of the Compose service name `mysql` | Use service hostnames inside Docker, not loopback addresses |
| Local behavior doesn't match staging/production | Version drift — native install not pinned to the same versions as the deployment guide | Prefer the Docker Compose setup, which pins exact versions |
| `schedule:work` fires tasks twice | Both `schedule:work` and a stray host cron entry running against the same project | `schedule:work` is a dev-only all-in-one; remove any local cron entries entirely |

---

## 14. Local Setup Checklist

- [ ] PHP 8.3–8.5 installed and confirmed (`php -v`); Composer 2.7+
- [ ] Project cloned via preferred method (§3)
- [ ] `docker compose up -d` (or native services) running, all containers/services healthy
- [ ] `.env` copied and filled per §4/§5 (matching Compose hostnames or native loopback, as applicable)
- [ ] `composer install`, `php artisan key:generate`, `php artisan migrate --seed` completed
- [ ] `composer run dev` (or the equivalent separate processes) starts cleanly with no errors
- [ ] App reachable at `http://localhost:8000`; Vite HMR working via `http://localhost:5173`
- [ ] Reverb WebSocket connects (check browser console / Telescope for a successful handshake)
- [ ] A test queued job processes successfully through the local RabbitMQ container
- [ ] Mailpit shows outgoing mail during manual testing (`http://localhost:8025`)
- [ ] Pint and PHPStan run clean (`./vendor/bin/pint --test`, `./vendor/bin/phpstan analyse`)
- [ ] Test suite passes (`php artisan test`)

---

## Appendix A — Windows Developers: Docker vs WSL2

This isn't really an either/or choice — modern Docker Desktop *runs on* WSL2 under the hood. The actual decision is between two setups:

1. **Docker Desktop with the WSL2 backend**, running the §4 Compose stack — recommended default.
2. **Native install with no Docker at all**, run directly inside a WSL2 Ubuntu distro (§5's commands, unmodified, since WSL2 is a real Ubuntu kernel) — a valid alternative for specific situations, covered below.

### Recommendation: Docker Desktop + WSL2 backend, project files living inside WSL2

This combination gives full version parity with production (the exact same Compose file and image tags from §4, unmodified) plus filesystem performance close to native Linux — **provided the project isn't sitting on the Windows-side filesystem.**

**The performance pitfall to avoid:** Docker Desktop's bind-mount performance is fine when project files live inside the Linux (WSL2) filesystem, but becomes noticeably slow when the project sits under `C:\Users\...` (equivalently `/mnt/c/...` from inside WSL2) and gets bind-mounted into a container — every file access crosses a network-filesystem boundary between the Windows and Linux sides. This single mistake accounts for most "Docker is slow on Windows" reports.

**Setup steps:**
1. Install Docker Desktop; in Settings → Resources → WSL Integration, enable integration for your WSL2 Ubuntu distro.
2. Open a **WSL2 terminal** (not PowerShell/CMD) and clone the project there: `cd ~ && git clone git@github.com:<org>/<repo>.git` — this puts the code on the Linux filesystem, e.g. `/home/<you>/<repo>`.
3. Run every `docker compose` command from that same WSL2 terminal.
4. Open the project in your editor via its WSL/remote integration — in VS Code, install the "Remote - WSL" extension and use "Reopen in WSL," rather than opening the folder from the Windows side.

Following these four steps, the Compose stack in §4 works exactly as written, with no changes needed for Windows.

### When native-in-WSL2 (no Docker) is the better call

- A solo developer or very small team where version drift across machines is a manageable risk, not a real one.
- A resource-constrained machine — Docker Desktop's Linux VM carries real memory/CPU overhead on top of what the services themselves use.
- A specific tool that doesn't containerize cleanly for your workflow (certain IDE debuggers, some Xdebug configurations).

In this case, follow §5's native install commands **inside the WSL2 Ubuntu distro** exactly as written — they're standard Ubuntu commands and need no Windows-specific changes. The tradeoff moves from "automatic parity via pinned image tags" to "developer discipline": periodically check installed versions (`php -v`, `mysql --version`, etc.) against the deployment guide's pinned versions and the table in §10, since nothing enforces that alignment automatically the way Docker's image tags do.

### What not to do

- Don't run Docker Desktop on the legacy Hyper-V backend if WSL2 is available — WSL2 is faster and is Docker Desktop's current default.
- Don't split the toolchain across both sides — e.g., project files on `C:\`, with some services in WSL2 and others running natively on Windows. Pick one environment (WSL2, for either Docker or native) and keep the entire toolchain — editor, terminal, git, code checkout — inside it.

---

## Appendix B — Docker Desktop Kubernetes: One Shared Context for Host, WSL2, and Containers

Some teams also use Docker Desktop's built-in single-node Kubernetes cluster to rehearse manifests, Helm charts, or ingress rules destined for a real cluster later — without every developer separately installing and maintaining `minikube`/`kind` on top of what Docker Desktop already provides. This doesn't replace anything in §4 (the Laravel stack there doesn't run on Kubernetes), it's an addition for teams that need it. Goal: `kubectl` on the Windows host, `kubectl` inside a WSL2 terminal, and `kubectl` running inside a container all point at the **exact same cluster**, not three independent copies of a kubeconfig that can drift apart.

### 1. Enable Kubernetes in Docker Desktop

Settings → **Kubernetes** tab → toggle **Enable Kubernetes** → Apply & Restart. On Docker Desktop 4.38+ you'll be asked to choose a provisioning method (**kubeadm** or **kind**) if signed in — either works for local dev. This provisions a single-node cluster inside Docker Desktop's own VM and writes (or merges) a `docker-desktop` context into the Windows-side kubeconfig at `C:\Users\<you>\.kube\config`.

### 2. Confirm on the host

```powershell
kubectl config get-contexts
kubectl config use-context docker-desktop
kubectl get nodes
```

If `get-contexts` comes back empty, run it from an actual CMD/PowerShell window rather than another shell, or set `KUBECONFIG` explicitly to the path above.

### 3. Share that same context into WSL2

Docker Desktop's WSL integration shares the Docker **engine** into your enabled distros automatically, but the kubeconfig file itself isn't guaranteed to be mirrored into every distro depending on your Docker Desktop version. The reliable fix is to have WSL2 read the *same file* the host uses, rather than maintaining two copies that can silently diverge:

```bash
mkdir -p ~/.kube
ln -sf /mnt/c/Users/<you>/.kube/config ~/.kube/config
```

or, equivalently, without a symlink:

```bash
echo 'export KUBECONFIG=/mnt/c/Users/<you>/.kube/config' >> ~/.bashrc && source ~/.bashrc
```

Then, from the same WSL2 terminal you're already using for the Laravel project (Appendix A):

```bash
kubectl config use-context docker-desktop
kubectl get nodes    # same single node the host saw in step 2
```

### 4. Reach the same cluster from inside a container

This is the part that needs distinct handling: `127.0.0.1`/`localhost` inside a container refers to the container itself, never the host running Docker Desktop's Kubernetes API server.

- Docker Desktop exposes the host to containers via the built-in DNS name **`host.docker.internal`**, which resolves correctly out of the box on Docker Desktop for Windows/Mac. (If you ever do this on a native Linux Docker host instead of Docker Desktop, add `--add-host=host.docker.internal:host-gateway`, or the equivalent Compose `extra_hosts` entry, to get the same resolution there.)
- Don't edit the live kubeconfig in place — Docker Desktop regenerates it. Keep a **separate, container-only copy** checked into the project instead (e.g. `docker/kube/config-for-containers.yaml`), with its `server:` field changed to `https://host.docker.internal:6443`, and mount that copy read-only:

```yaml
# docker-compose.yml snippet
services:
  kubectl-toolbox:
    image: bitnami/kubectl:latest
    volumes:
      - ./docker/kube/config-for-containers.yaml:/root/.kube/config:ro
    entrypoint: ["kubectl"]
```

- Certificate validation can still fail even once the network path is right, if the API server's TLS certificate wasn't issued with `host.docker.internal` as a valid name. Check what the certificate actually covers before assuming it will fail:

```bash
kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 -d > ca.crt
openssl x509 -in ca.crt -noout -text | grep -A1 "Subject Alternative Name"
```

If `host.docker.internal` isn't listed, the practical dev-only fallback is `insecure-skip-tls-verify: true` on that **container-only** kubeconfig copy specifically. Never set this on the host or WSL2 copies, and never use it for anything beyond this single-node local cluster.

### 5. Verify all three actually agree

```bash
# Host (PowerShell)
kubectl config current-context   # docker-desktop
kubectl get nodes

# WSL2
kubectl config current-context   # docker-desktop
kubectl get nodes                # same node name/age as the host

# Container
docker compose run --rm kubectl-toolbox get nodes   # same node again, reached via host.docker.internal
```

If all three report the same node name and age, the host, WSL2, and the container are genuinely talking to one cluster — not three independent ones that happen to look similar.
