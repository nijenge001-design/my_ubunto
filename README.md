# Bash Aliases Collection

A practical Bash toolkit for speeding up common **Docker, Docker Compose, Laravel, Livewire, Git, Node/NPM, WSL, and MySQL** workflows.

Short aliases cover repetitive commands. Helper functions cover cleanup, service shells, shared MySQL, the local WSL stack, and git archives.

The alias file is `dev-aliases.sh`. Copy it to `~/.bash_aliases`, or source it directly.

---

## What this includes

| Area | What you get |
|---|---|
| Docker | Container, image, network, volume, cleanup, shell, log, and resource shortcuts |
| Docker Compose | Start, stop, rebuild, reset, logs, and per-service helpers |
| Laravel | Artisan, generators (`am*`), migrations, queues, storage, Sail |
| Livewire | Component, page, form, and layout generators |
| Git | Status, commit, push, pull, soft reset, and archive helpers |
| Node/NPM | `dev` and `build` |
| Shared MySQL | Create users and databases on a Compose MySQL service |
| WSL MySQL | The same jobs against local systemd MySQL |
| WSL stack | Status, ports, and health for MySQL, PostgreSQL, Redis, Memcached, Mailpit, RabbitMQ |

---

# Installation

## 1. Copy the aliases file

```bash
cp dev-aliases.sh ~/.bash_aliases
```

## 2. Load it from `~/.bashrc`

Add this if it is not already present:

```bash
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
```

## 3. Reload Bash

```bash
source ~/.bashrc
# or
sb
```

Optional overrides, set before the file is sourced:

```bash
export DC_SHARED_SERVICES="$HOME/docker/shared-services"
export DC_MYSQL_SERVICE="mysql"          # or mariadb
export MYSQL_ROOT_PASSWORD="secret"      # used by dc-* and wsl-* MySQL helpers
export GAR_ONE_DIR="/mnt/c/Users/YOU/OneDrive - YOUR_ORG/wsl_project"
export STACK_SERVICES=(mysql postgresql redis-server memcached mailpit rabbitmq-server)
```

`STACK_SERVICES` is assigned inside the file. To override it, edit that line or reassign it after sourcing.

---

# Quick reference

## General / shell

| Alias | Command | Purpose |
|---|---|---|
| `sb` | `source ~/.bashrc` | Reload Bash configuration |
| `cls` | `clear` | Clear the terminal |
| `ll` | `ls -lah` | Long listing, including hidden files |
| `la` | `ls -A` | List almost all files |
| `l` | `ls -CF` | Column listing |
| `..` | `cd ..` | Up one directory |
| `...` | `cd ../..` | Up two directories |
| `myip` | `hostname -I` | Local IP addresses |
| `os-v` | `lsb_release -a` | OS version |
| `ports` | `ss -tulnp` | Listening ports |
| `all-apps` | `apt-mark showmanual` | Manually installed packages |
| `p2kill` | `sudo ss -tulpn \| grep` | Find a listener. Does not kill |
| `fphp` | `/usr/bin/frankenphp php-cli` | PHP via FrankenPHP |
| `treel` | `tree -L` | Tree to a depth: `treel 2` |

---

# Git

| Alias | Command | Purpose |
|---|---|---|
| `gs` | `git status` | Working-tree status |
| `ga` | `git add .` | Stage all changes |
| `gc` | `git commit -m` | Commit with a message |
| `gp` | `git push` | Push |
| `gl` | `git pull` | Pull |
| `greset1` | `git reset --soft HEAD~1` | Undo the last commit, keep changes staged |

`greset` (delete the `HEAD` ref) is intentionally not defined. Use `greset1`.

---

# Node / frontend

| Alias | Command | Purpose |
|---|---|---|
| `dev` | `npm run dev` | Start the frontend dev server |
| `build` | `npm run build` | Production build |

---

# Docker

## Basic

| Alias | Purpose |
|---|---|
| `d-ps` | Running containers |
| `d-psa` | All containers |
| `d-images` | Local images |
| `d-inspect` | Full JSON for a container, image, network, or volume |
| `d-logs` | Follow a container's logs |
| `d-logs-n` | Follow logs, last 100 lines first |
| `d-history` | Image layers |
| `d-port` | Host-to-container port mappings |
| `d-top` | Live CPU, memory, and network. Ctrl+C to stop |

## Cleanup

| Alias | Purpose | Risk |
|---|---|---|
| `d-prune` | Unused containers, images, networks, and volumes | High |
| `d-prune-containers` | Stopped containers only | Medium |
| `d-prune-images` | Images not used by any container | Medium |
| `d-prune-volumes` | Unused volumes. Data in them is deleted | High |
| `d-prune-networks` | Networks with no connected container | Low |

## Networks

| Alias | Purpose |
|---|---|
| `dn-ls` | List networks |
| `dn-inspect` | Subnets, containers, and driver |
| `dn-create` | Create a bridge network |
| `dn-prune` | Remove unused networks |

## Volumes

| Alias | Purpose |
|---|---|
| `dv-ls` | List volumes |
| `dv-inspect` | Mount point and labels |
| `dv-create` | Create a named volume |
| `dv-prune` | Remove unused volumes. Deletes their data |

---

# Docker Compose

Compose commands use `compose.yaml` in the current directory.

## Common

| Alias | Command | Purpose |
|---|---|---|
| `dc-u` | `docker compose up -d` | Start in the background. Build only if the image is missing |
| `dc-ub` | `docker compose up -d --build` | Rebuild images, then start |
| `dc-d` | `docker compose down` | Stop and remove containers and the project network. Volumes stay |
| `dc-dv` | `docker compose down -v` | Down, and delete volumes declared in the compose file |
| `dc-do` | `docker compose down -v --remove-orphans` | `down -v`, plus containers no longer in the file |
| `dc-re` | `docker compose restart` | Restart running services. No rebuild |
| `dc-l` | `docker compose logs -f` | Follow logs for every service |
| `dc-l100` | `docker compose logs -f --tail=100` | Follow logs, last 100 lines first |
| `dc-e` | `docker compose exec` | Run a command in a service: `dc-e app bash` |
| `dc-ps` | `docker compose ps` | Status of this project's services |
| `dc-stop` | `docker compose stop` | Stop without removing containers |
| `dc-start` | `docker compose start` | Start stopped containers without recreating them |
| `dc-pull` | `docker compose pull` | Pull newer images |
| `dc-config` | `docker compose config` | Print the resolved compose file |

## Advanced

| Alias | Purpose | Risk |
|---|---|---|
| `dc-dbu` | Wipe compose volumes, rebuild, start | High |
| `dc-db` | Same as `dc-dbu`, plus remove orphans | High |
| `dc-upd` | Recreate containers even if config did not change | Low |
| `dc-b` | Build with no cache | Low |
| `dc-bup` | No-cache build, then start | Low |
| `dc-down-all` | Remove containers, volumes, project images, and orphans | High |

---

# Laravel

## Core

| Alias | Command | Purpose |
|---|---|---|
| `a` | `php artisan` | Artisan shortcut. Other aliases expand through this |
| `crd` | `composer run dev` | Composer dev script |
| `pad` | `php artisan dev` | Artisan dev server |
| `ln` | `laravel new` | New Laravel project |

## Routes, storage, Sail

| Alias | Command | Purpose |
|---|---|---|
| `rc` | `route:cache` | Cache routes |
| `rcl` | `route:clear` | Clear the route cache |
| `rl` | `route:list` | List routes |
| `sl` | `storage:link` | Link `public/storage` |
| `sul` | `storage:unlink` | Remove that link |
| `sp` | `stub:publish` | Publish stubs |
| `sail` | project `sail` or `vendor/bin/sail` | Sail wrapper |
| `sa` | `sail:add` | Add a Sail service |
| `si` | `sail:install` | Install Sail |
| `spub` | `sail:publish` | Publish Sail files |
| `add-sail` | `composer require laravel/sail --dev` | Require Sail |
| `install-sail` | `php artisan sail:install` | Install Sail |

## Make (`am*`)

| Alias | Creates |
|---|---|
| `amc` | Class |
| `amcmd` | Command |
| `amcmp` | Component |
| `amctl` | Controller |
| `amen` | Enum |
| `amev` | Event |
| `amf` | Factory |
| `ami` | Interface |
| `amj` | Job |
| `aml` | Listener |
| `amm` | Mail |
| `ammw` | Middleware |
| `ammg` | Migration |
| `ammo` | Model |
| `amnt` | Notification |
| `amntt` | Notifications table |
| `amob` | Observer |
| `amp` | Policy |
| `ampr` | Provider |
| `amqb` | Queue batches table |
| `amqf` | Queue failed-jobs table |
| `amqt` | Queue jobs table |
| `amr` | Form request |
| `amrs` | API resource |
| `amrule` | Validation rule |
| `amsc` | Scope |
| `amsd` | Seeder |
| `amst` | Sessions table |
| `amt` | Test |
| `amtr` | Trait |
| `amv` | View |

Older names such as `mctl` and `mmo` are not defined. Use `amctl` and `ammo`.

## Migrations (`mg*`)

| Alias | Command | Purpose |
|---|---|---|
| `mg` | `migrate` | Run pending migrations |
| `mgf` | `migrate:fresh` | Drop all tables and migrate. Destroys data |
| `mgi` | `migrate:install` | Create the migrations table |
| `mgr` | `migrate:refresh` | Roll back and re-run |
| `mgreset` | `migrate:reset` | Roll back all migrations |
| `mgb` | `migrate:rollback` | Roll back the latest batch |
| `mgs` | `migrate:status` | Migration status |

## Database (`db*`)

| Alias | Command | Purpose |
|---|---|---|
| `dbm` | `db:monitor` | Monitor connections |
| `dbs` | `db:seed` | Run seeders |
| `dbsh` | `db:show` | Show database info |
| `dbt` | `db:table` | Show one table |
| `dbw` | `db:wipe` | Drop all tables, views, and types |

## Queue

| Alias | Command | Purpose |
|---|---|---|
| `qc` | `queue:clear` | Clear a queue |
| `qf` | `queue:failed` | List failed jobs |
| `qfl` | `queue:flush` | Flush failed jobs |
| `qfg` | `queue:forget` | Forget one failed job |
| `ql` | `queue:listen` | Listen for jobs |
| `qm` | `queue:monitor` | Monitor queues |
| `qpb` | `queue:prune-batches` | Prune job batches |
| `qpf` | `queue:prune-failed` | Prune failed jobs |
| `qr` | `queue:restart` | Signal workers to restart |
| `qrt` | `queue:retry` | Retry a failed job |
| `qrb` | `queue:retry-batch` | Retry a batch |
| `qw` | `queue:work` | Start a worker |

## Livewire

| Alias | Creates / runs |
|---|---|
| `mlw` | Livewire component |
| `mlwp` | Livewire page: `mlwp Dashboard` |
| `lwa` | Livewire attribute |
| `lwc` | Livewire config |
| `lwcv` | Convert a component |
| `lwf` | Livewire form |
| `lwl` | Livewire layout |
| `lws` | Publish Livewire stubs |
| `pstress` | `./vendor/bin/pest stress ` |

## Laravel Idea

| Alias | Purpose |
|---|---|
| `ideu` | Remove `vendor/_laravel_idea` and dump autoload |
| `ide-update` | Same, with status output. Must be run from a Laravel project |

---

# Helper functions

## Docker

```bash
docker-clean-safe                         # prune containers, images, networks; keep volumes
docker-summary                            # containers, images, volumes, networks
docker-shell <container> [shell]          # default shell /bin/bash
docker-logs-with-time <container> [lines] # follow logs with timestamps, default 50 lines
```

## Compose services

```bash
dc-service-up <service>                   # rebuild and start one service
dc-service-re <service>                   # restart one service, no rebuild
dc-service-logs <service> [lines]         # follow one service, default 50 lines
dc-service-shell <service> [shell]        # shell in a service, default /bin/bash
```

## Shared MySQL (Compose)

These run against `$DC_SHARED_SERVICES` (default `~/docker/shared-services`) from any directory. The service defaults to `$DC_MYSQL_SERVICE` (`mysql`). Root password is `$MYSQL_ROOT_PASSWORD`, otherwise `MYSQL_ROOT_PASSWORD` in that project's `.env`.

Users are created as `'user'@'%'`. Password defaults to the username. Database charset is `utf8mb4` / `utf8mb4_unicode_ci`.

```bash
dc-mkuser <username> [password] [service]
dc-mkdbonly <database> [service]
dc-mkdb <database> [username] [password] [service]
dc-adduser <database> [username] [service]   # both must already exist
dc-rmdb <database> [username] [service]      # asks first; DC_FORCE=1 skips the prompt
dc-reset [service...]                        # down -v && up -d for the shared project
```

`dc-reset` dumps `./backups/all-databases-<timestamp>.sql` first, unless `DC_NO_BACKUP=1`. `DC_FORCE=1` skips the confirm prompt. It deletes every volume in that compose project.

## WSL MySQL (local systemd)

Same jobs, against MySQL on `127.0.0.1`. Auth is `$MYSQL_ROOT_PASSWORD` if set, otherwise `sudo mysql` (Ubuntu auth_socket). Each user is created as both `'user'@'%'` and `'user'@'localhost'`.

```bash
wsl-mkuser <username> [password]
wsl-mkdbonly <database>
wsl-mkdb <database> [username] [password]
wsl-adduser <database> [username]
wsl-rmdb <database> [username]               # DC_FORCE=1 skips the prompt
```

## Git archives

```bash
garc <ProjectName> [path...]                 # ./<ProjectName>.zip; GARC_OUT overrides the folder
gout <outdir> <ProjectName> [path...]
gar_one <ProjectName> [path...]              # OneDrive; GAR_ONE_DIR overrides the path
```

Default OneDrive path: `/mnt/c/Users/SGL/OneDrive - Contoso/wsl_project`.

## WSL local stack

Units come from `STACK_SERVICES`: `mysql`, `postgresql`, `redis-server`, `memcached`, `mailpit`, `rabbitmq-server`. Redis on Ubuntu is `redis-server`, not `redis`.

| Alias / function | Purpose |
|---|---|
| `st-mysql` `st-pg` `st-redis` `st-memcached` `st-mailpit` `st-rabbit` | `systemctl status` for one unit |
| `stack-status` / `stack-active` | `is-active` for every unit |
| `stack-check` | state, substate, pid, since |
| `stack-table` | same data as a table |
| `stack-status-full` | full `systemctl status` for every unit |
| `stack-ports` | listeners on 3306, 5432, 6379, 11211, 1025, 8025, 5672, 15672 |
| `stack-health` | status plus mysqladmin, pg_isready, redis, memcached, Mailpit, RabbitMQ |
| `stack-urls` | RabbitMQ `http://localhost:15672`, Mailpit `http://localhost:8025` |

---

# Usage examples

## Docker

```bash
d-ps
d-psa
d-images
d-port my-app
d-top
d-logs my-app
d-logs-n my-app
docker-shell my-app
docker-shell my-app sh
docker-logs-with-time my-app 200
docker-clean-safe
docker-summary
```

## Compose

```bash
dc-u
dc-ub
dc-ps
dc-l
dc-l100
dc-service-logs app 200
dc-e app bash
dc-service-shell app
dc-service-up app
dc-service-re app
dc-config
```

`dc-dv`, `dc-do`, `dc-db`, `dc-dbu`, and `dc-down-all` delete volumes. Use them only when that is the point.

## Laravel

```bash
ln my-project
cd my-project
crd

a route:list
rl

amctl EmployeeController
ammo Employee
ammg create_employees_table
amr StoreEmployeeRequest
amrs EmployeeResource
amp EmployeePolicy
amj ProcessEmployeeImport

mg
mgs
mgb
```

`mgf` and `dbw` destroy the database. Do not run them against production.

```bash
mlw EmployeeTable
mlwp Employees/Index
lwf EmployeeForm
lwl AppLayout

qw
qf
qrt 5
qr
```

## Shared and local MySQL

```bash
# Compose MySQL in ~/docker/shared-services
dc-mkdb attendance attendance secret
dc-adduser attendance reports
dc-rmdb attendance

# Local systemd MySQL
wsl-mkdb attendance attendance secret
wsl-adduser attendance reports
DC_FORCE=1 wsl-rmdb attendance
```

## Git and archives

```bash
gs
ga
gc "Add employee management"
gp
gl
greset1

garc MyApp app routes resources
gout ~/backups MyApp
GAR_ONE_DIR="/mnt/c/Users/YOU/OneDrive/wsl_project" gar_one MyApp
```

## WSL stack

```bash
stack-table
stack-health
stack-ports
stack-urls
st-redis
```

## Session sketch

```bash
cd ~/projects/my-erp
dc-ub
dc-ps
dc-e app bash
# inside the container
mg
mgs
exit
dc-service-logs app
gs
ga
gc "Update employee management"
gp
```

---

# Which command

| Task | Command |
|---|---|
| Reload Bash | `sb` |
| Find who owns a port | `p2kill :8080` |
| Git status | `gs` |
| Undo last commit, keep changes | `greset1` |
| Start Compose | `dc-u` |
| Build and start Compose | `dc-ub` |
| Compose status | `dc-ps` |
| Compose logs | `dc-l` |
| Shell in a container | `docker-shell <container>` |
| Artisan | `a <command>` |
| Controller | `amctl <name>` |
| Model | `ammo <name>` |
| Migration file | `ammg <name>` |
| Run migrations | `mg` |
| Livewire component | `mlw <name>` |
| Queue worker | `qw` |
| Create a Compose database | `dc-mkdb <db> [user] [pass]` |
| Create a local database | `wsl-mkdb <db> [user] [pass]` |
| Stack table | `stack-table` |
| Project archive | `garc <ProjectName>` |

Check what an alias expands to:

```bash
type amctl
alias dc-u
```

---

# Customization

OneDrive path for `gar_one`:

```bash
export GAR_ONE_DIR="/mnt/c/Users/YOUR_USERNAME/OneDrive - YOUR_ORG/wsl_project"
```

Shared Compose MySQL:

```bash
export DC_SHARED_SERVICES="$HOME/docker/shared-services"
export DC_MYSQL_SERVICE="mysql"
export MYSQL_ROOT_PASSWORD="secret"
```

Add your own aliases at the end of the file:

```bash
# ============================================
# CUSTOM ALIASES
# ============================================
alias myalias='my command'
```

---

# Safety

| Command | Action | Risk |
|---|---|---|
| `d-prune` | Unused Docker data, including volumes | High |
| `d-prune-volumes` / `dv-prune` | Delete unused volume data | High |
| `dc-dv` `dc-do` `dc-db` `dc-dbu` `dc-down-all` | Delete Compose volumes | High |
| `dc-reset` | Delete every volume in the shared project | High |
| `dc-rmdb` / `wsl-rmdb` | Drop a database and its user | High |
| `mgf` | Drop all tables and re-migrate | High |
| `dbw` | Drop all tables, views, and types | High |
| `greset1` | Undo the last commit. Changes stay staged | Medium |

`dc-rmdb`, `wsl-rmdb`, and `dc-reset` ask before they run. `DC_FORCE=1` skips that prompt. `dc-reset` writes a dump first unless `DC_NO_BACKUP=1`.

`p2kill` only searches. It does not kill the process.

Read the definition before running a destructive alias against anything you care about.

---

# Requirements

- Bash 4.0+ (arrays in the stack helpers)
- Docker and Docker Compose v2 (`docker compose`)
- PHP, Composer, and the Laravel installer for the Laravel aliases
- Git
- Node.js and npm for `dev` / `build`
- MySQL client, and `sudo` for the WSL helpers when `MYSQL_ROOT_PASSWORD` is unset
- `ss` from iproute2 (`ports`, `p2kill`, `stack-ports`)

FrankenPHP, Sail, Livewire, Pest, Redis, PostgreSQL, Memcached, Mailpit, and RabbitMQ are only needed for the aliases that call them.
