# Ubuntu 26.04 (Resolute) LEMP + FrankenPHP (PHP 8.5 ZTS) Setup Guidelines

**Environment:** Ubuntu 26.04.1 LTS (codename `resolute`)  
**Target stack:** Nginx (reverse proxy) → FrankenPHP (Caddy + PHP 8.5 ZTS) + PostgreSQL 18 + MySQL 8.4 + Python 3.14 + Composer  
**Date of reference session:** 2026-09-23  

These guidelines distill a real installation session: what worked, what failed, correct package names, service configuration, and recommended practices.

---

## 1. System baseline

```bash
lsb_release -a
# Distributor ID: Ubuntu
# Description:    Ubuntu 26.04.1 LTS
# Release:        26.04
# Codename:       resolute

sudo apt update && sudo apt upgrade -y
sudo apt install -y software-properties-common ca-certificates curl gnupg \
  lsb-release apt-transport-https unzip git build-essential
```

- Always run `apt update` before installing new packages.
- `build-essential` pulls in gcc-15, g++, make, etc. (needed for some native extensions later).

---

## 2. Python

Ubuntu 26.04 ships **Python 3.14** as the system interpreter. There is no `python` binary by default.

```bash
python3 --version          # Python 3.14.4
sudo apt install -y python3-pip python-is-python3
python --version           # now works (symlink to python3)
```

- `python-is-python3` provides the `python` command.
- Prefer `python3 -m venv` and `python3 -m pip` for isolation.
- System `pip` is available after installing `python3-pip`.

---

## 3. Nginx

```bash
sudo apt install -y nginx
sudo systemctl enable --now nginx
sudo systemctl status nginx --no-pager
```

- Default site is enabled; we replace it later when proxying to FrankenPHP.
- Config test: `sudo nginx -t`
- Reload: `sudo systemctl reload nginx`

---

## 4. PostgreSQL 18

```bash
sudo apt install -y postgresql postgresql-contrib
sudo systemctl enable --now postgresql
sudo -u postgres psql -c "SELECT version();"
# PostgreSQL 18.6 (Ubuntu 18.6-0ubuntu0.26.04.1)
```

- Cluster is created automatically under `/var/lib/postgresql/18/main`.
- Auth: local = peer, host = scram-sha-256.
- Time zone follows system (`Africa/Johannesburg` in the reference session).

---

## 5. MySQL 8.4

```bash
sudo apt install -y mysql-server
sudo systemctl enable --now mysql
sudo mysql_secure_installation
mysql --version
# mysql  Ver 8.4.11-0ubuntu0.26.04.1
```

**Secure installation notes (interactive):**

| Prompt | Recommended answer |
|--------|--------------------|
| VALIDATE PASSWORD component | Y → policy MEDIUM (1) |
| Set root password | Skipped (auth_socket is used by default) |
| Remove anonymous users | Y |
| Disallow root login remotely | Y |
| Remove test database | Y |
| Reload privilege tables | Y |

- Root uses `auth_socket`; for password auth later:  
  `sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '…';"`

---

## 6. FrankenPHP + PHP 8.5 ZTS (Static PHP)

### 6.1 Add the repository (correct way)

The reference session hit a **Signed-By conflict** because the key was added twice under different filenames. Use a single clean source:

```bash
VERSION=85   # PHP 8.5
sudo mkdir -p /etc/apt/keyrings

# Preferred: official installer script (idempotent when done correctly)
curl -fsSL https://files.henderkes.com/install.sh | sudo sh -s ${VERSION}

# OR manual (ensure only ONE list entry exists):
# sudo curl -fsSL https://pkg.henderkes.com/api/packages/${VERSION}/debian/repository.key \
#   -o /etc/apt/keyrings/henderkes${VERSION}.asc
# echo "deb [signed-by=/etc/apt/keyrings/henderkes${VERSION}.asc] \
#   https://pkg.henderkes.com/api/packages/${VERSION}/debian php-zts main" \
#   | sudo tee /etc/apt/sources.list.d/static-php${VERSION}.list

# Fix if you already have a conflict:
# cat /etc/apt/sources.list.d/static-php85.list
# → keep only the line that points to henderkes85.asc (or static-php85.asc)
# then:
sudo apt update
```

**Critical:** Never leave two `deb` lines with different `signed-by=` values for the same URL.

### 6.2 Install FrankenPHP and base PHP ZTS

```bash
sudo apt install -y frankenphp php-zts-cli php-zts-embed
frankenphp version
php-zts -v
# PHP 8.5.10 (cli) (built: …) (ZTS …)
```

- Binary names: `frankenphp`, `php-zts` (not plain `php`).
- Thread Safety is **enabled** (`php-zts -i | grep 'Thread Safety'`).

### 6.3 PHP extensions – correct package names

There is **no** package named `php-zts-mysql`. Use the split packages:

| Purpose              | Correct package(s)                          |
|----------------------|---------------------------------------------|
| MySQL                | `php-zts-mysqli` `php-zts-pdo-mysql` `php-zts-mysqlnd` |
| PostgreSQL           | `php-zts-pgsql` `php-zts-pdo-pgsql`         |
| SQLite               | `php-zts-sqlite3` `php-zts-pdo-sqlite`      |
| Core utilities       | `php-zts-bcmath` `php-zts-bz2` `php-zts-gd` `php-zts-gmp` `php-zts-intl` `php-zts-zip` `php-zts-soap` `php-zts-ffi` `php-zts-ftp` `php-zts-gettext` `php-zts-xsl` |
| Imaging / cache      | `php-zts-imagick` `php-zts-redis` `php-zts-apcu` |
| Debug / profile      | `php-zts-xdebug` `php-zts-xhprof` `php-zts-pcov` `php-zts-spx` |
| Async / modern       | `php-zts-swoole` `php-zts-parallel` `php-zts-uv` `php-zts-event` `php-zts-ev` |
| Other useful         | `php-zts-mongodb` `php-zts-memcached` `php-zts-amqp` `php-zts-rdkafka` `php-zts-grpc` `php-zts-yaml` `php-zts-uuid` … |

**Install a practical set:**

```bash
sudo apt install -y \
  php-zts-bcmath php-zts-bz2 php-zts-gd php-zts-gmp \
  php-zts-intl php-zts-mysqli php-zts-pdo-mysql php-zts-mysqlnd \
  php-zts-pgsql php-zts-pdo-pgsql \
  php-zts-sqlite3 php-zts-pdo-sqlite \
  php-zts-zip php-zts-imagick php-zts-redis \
  php-zts-soap php-zts-ffi php-zts-ftp php-zts-gettext php-zts-xsl \
  php-zts-xdebug php-zts-xhprof php-zts-yaml php-zts-uuid
```

**Install everything available (minus debuginfo / meta packages):**

```bash
apt-cache search '^php-zts-' \
  | awk '{print $1}' \
  | grep -v -- '-debuginfo$' \
  | grep -Ev '^php-zts-(cli|cgi|fpm|embed|devel)$' \
  | sort -u \
  | xargs sudo apt install -y
```

### 6.4 Verify modules and configuration

```bash
php-zts -m | sort
php-zts -i | grep -E '^(PHP Version|Thread Safety|extension_dir)'
php-zts --ini
# Config: /etc/php-zts/php.ini
# Additional .ini: /etc/php-zts/conf.d/
# Modules: /usr/lib/php-zts/modules/
```

### 6.5 Make `php-zts` the default `php` (optional)

```bash
sudo update-alternatives --install /usr/bin/php php /usr/bin/php-zts 100
# Composer and many tools will then use the ZTS binary.
```

**Caveat:** The Ubuntu package `composer` pulls in the NTS `php8.5-cli`. After installing Composer you may want to re-point the alternative or invoke `php-zts` explicitly for ZTS-only work.

---

## 7. Composer

```bash
sudo apt install -y composer
composer --version
# Composer version 2.9.5 … PHP version 8.5.4 (/usr/bin/php8.5)  ← NTS
```

For a pure ZTS Composer experience:

```bash
curl -sS https://getcomposer.org/installer | sudo php-zts -- --install-dir=/usr/local/bin --filename=composer-zts
```

---

## 8. FrankenPHP as systemd service + Nginx reverse proxy

### 8.1 Document root

```bash
sudo mkdir -p /var/www/html/public
echo '<?php phpinfo();' | sudo tee /var/www/html/public/index.php
sudo chown -R www-data:www-data /var/www/html
```

### 8.2 Caddyfile

```bash
sudo mkdir -p /etc/frankenphp
sudo tee /etc/frankenphp/Caddyfile > /dev/null <<'EOF'
{
    servers {
        trusted_proxies static 127.0.0.1/32
    }

    frankenphp {
        num_threads 4          # ≈ 2 × physical cores is a good start
        # max_threads auto
    }
}

:8080 {
    bind 127.0.0.1

    root * /var/www/html/public
    encode zstd br gzip

    php_server {
        try_files {path} index.php
    }

    file_server
}
EOF
```

### 8.3 systemd unit

```bash
sudo tee /etc/systemd/system/frankenphp.service > /dev/null <<'EOF'
[Unit]
Description=FrankenPHP Application Server
Documentation=https://frankenphp.dev
After=network.target

[Service]
Type=notify
User=www-data
Group=www-data
ExecStart=/usr/bin/frankenphp run --config /etc/frankenphp/Caddyfile
ExecReload=/bin/kill -USR1 $MAINPID
TimeoutStopSec=5s
Restart=on-failure
RestartSec=5
LimitNOFILE=1048576
LimitNPROC=512
PrivateTmp=true
ProtectSystem=full
NoNewPrivileges=true
AmbientCapabilities=CAP_NET_BIND_SERVICE
CapabilityBoundingSet=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now frankenphp
sudo systemctl status frankenphp --no-pager
```

**Reload note:** `systemctl reload frankenphp` may fail if the unit does not fully support the reload signal yet. Prefer:

```bash
sudo systemctl restart frankenphp
# or
sudo kill -USR1 $(systemctl show -p MainPID --value frankenphp)
```

### 8.4 Nginx site

```bash
sudo tee /etc/nginx/sites-available/frankenphp > /dev/null <<'EOF'
map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      close;
}

server {
    listen 80;
    listen [::]:80;
    server_name localhost;   # change to your domain

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;

        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host  $host;
        proxy_set_header X-Forwarded-Port  $server_port;

        proxy_set_header Upgrade    $http_upgrade;
        proxy_set_header Connection $connection_upgrade;

        proxy_buffering off;
        proxy_request_buffering off;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    location ~ /\. {
        deny all;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/frankenphp /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl reload nginx
```

### 8.5 TLS (when you have a domain)

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com
```

---

## 9. Verification checklist

```bash
echo "=== Versions ==="
python3 --version
nginx -v
psql --version
mysql --version
php-zts -v
frankenphp version
composer --version

echo "=== PHP ZTS modules (sample) ==="
php-zts -m | head -30

echo "=== Services ==="
systemctl is-active nginx postgresql mysql frankenphp

echo "=== Quick HTTP test ==="
curl -sI http://127.0.0.1/ | head -5
curl -s http://127.0.0.1/ | grep -o 'PHP Version.*' | head -1
```

Expected:

- PHP 8.5.x ZTS with Thread Safety = enabled  
- Nginx → FrankenPHP on 127.0.0.1:8080  
- PostgreSQL 18 + MySQL 8.4 running  
- phpinfo() page served via the proxy  

---

## 10. Common pitfalls (from the reference session)

| Issue | Cause | Fix |
|-------|-------|-----|
| `Unable to locate package php-zts-mysql` | Package does not exist | Use `php-zts-mysqli` + `php-zts-pdo-mysql` + `php-zts-mysqlnd` |
| `Conflicting values set for option Signed-By` | Two list entries with different key files | Keep a single `deb` line in `/etc/apt/sources.list.d/static-php85.list` |
| `frankenphp php-cli -v` fails | Wrong sub-command usage | Use `php-zts -v` or `frankenphp version` |
| `systemctl reload frankenphp` fails | Unit reload support incomplete | Use `restart` or send USR1 manually |
| Composer uses NTS PHP | Ubuntu `composer` depends on `php8.5-cli` | Install Composer with `php-zts` or set `update-alternatives` |
| HTTP/2 & HTTP/3 warnings | Listening on plain HTTP (127.0.0.1:8080) | Expected; TLS is terminated at Nginx/Certbot |

---

## 11. Recommended production hardening (next steps)

1. Replace `server_name localhost` with a real domain and obtain certificates.
2. Tune `num_threads` in the Caddyfile to match CPU cores.
3. Restrict PostgreSQL/MySQL to local socket or specific networks.
4. Enable `opcache` validation and consider APCu for user-space caching.
5. Put application code under `/var/www/html` (or a dedicated user home) with proper ownership.
6. Consider a dedicated system user for FrankenPHP instead of `www-data` if isolation is required.
7. Add a firewall (`ufw allow 80,443`) and fail2ban if exposed to the internet.

---

## 12. Quick reference – key paths

| Item | Path |
|------|------|
| PHP ZTS binary | `/usr/bin/php-zts` |
| FrankenPHP binary | `/usr/bin/frankenphp` |
| PHP ini | `/etc/php-zts/php.ini` |
| Extra ini | `/etc/php-zts/conf.d/` |
| Modules | `/usr/lib/php-zts/modules/` |
| Caddyfile | `/etc/frankenphp/Caddyfile` |
| systemd unit | `/etc/systemd/system/frankenphp.service` |
| Nginx site | `/etc/nginx/sites-available/frankenphp` |
| Document root | `/var/www/html/public` |
| FrankenPHP state | `/var/lib/frankenphp/` |

---

*Generated from a real Ubuntu 26.04 + FrankenPHP 1.12.7 / PHP 8.5.10 ZTS installation session. Keep this file as a living checklist for future servers.*
