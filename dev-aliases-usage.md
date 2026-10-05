# Dev aliases — usage

Source: `dev-aliases.sh`

Shared database commands run in `$DC_SHARED_SERVICES` (default `~/docker/shared-services`), against `$DC_MYSQL_SERVICE` (default `mysql`). Root password is `$MYSQL_ROOT_PASSWORD`, otherwise `MYSQL_ROOT_PASSWORD` in that project's `.env`.

## Functions

| Function | Usage | Examples | What it does |
|---|---|---|---|
| `docker-clean-safe` | `docker-clean-safe` | `docker-clean-safe` | Prune stopped containers, unused images, and unused networks. Volumes are kept. |
| `docker-summary` | `docker-summary` | `docker-summary` | Print containers, images, volumes, and networks. |
| `docker-shell` | `docker-shell <container> [shell]` | `docker-shell app`<br>`docker-shell app /bin/sh` | Interactive shell in a running container. Shell defaults to `/bin/bash`. |
| `dc-service-up` | `dc-service-up <service>` | `dc-service-up nginx` | Rebuild and start one Compose service in the current directory. |
| `dc-service-re` | `dc-service-re <service>` | `dc-service-re redis` | Restart one Compose service. No rebuild. |
| `dc-service-logs` | `dc-service-logs <service> [lines]` | `dc-service-logs app`<br>`dc-service-logs app 200` | Follow one service's logs. Default 50 lines. |
| `dc-service-shell` | `dc-service-shell <service> [shell]` | `dc-service-shell app`<br>`dc-service-shell app sh` | Shell in a Compose service. Shell defaults to `/bin/bash`. |
| `docker-logs-with-time` | `docker-logs-with-time <container> [lines]` | `docker-logs-with-time nginx`<br>`docker-logs-with-time app 100` | Follow container logs with timestamps. Default 50 lines. |
| `dc-mkuser` | `dc-mkuser <username> [password] [service]` | `dc-mkuser appuser`<br>`dc-mkuser appuser secret`<br>`dc-mkuser appuser 'p!@#$%^&*()'`<br>`dc-mkuser appuser secret mariadb` | Create a MySQL user only (`'user'@'%'`). No database, no grant. Password defaults to the username. Quote a password that contains `!@#$%^&*()` so the shell does not expand it. |
| `dc-mkdbonly` | `dc-mkdbonly <database> [service]` | `dc-mkdbonly myapp`<br>`dc-mkdbonly myapp mariadb` | Create a database only (`utf8mb4` / `utf8mb4_unicode_ci`). No user, no grant. |
| `dc-mkdb` | `dc-mkdb <database> [username] [password] [service]` | `dc-mkdb myapp`<br>`dc-mkdb myapp appuser`<br>`dc-mkdb myapp appuser secret` | Create database, user, and grant. User defaults to the database name; password defaults to the user. |
| `dc-adduser` | `dc-adduser <database> [username] [service]` | `dc-adduser myapp`<br>`dc-adduser myapp appuser` | Grant an existing user an existing database. Fails if either is missing. User defaults to the database name. |
| `dc-rmdb` | `dc-rmdb <database> [username] [service]` | `dc-rmdb myapp`<br>`dc-rmdb myapp appuser`<br>`DC_FORCE=1 dc-rmdb myapp` | Drop a database and user. Asks first unless `DC_FORCE=1`. User defaults to the database name. |
| `dc-reset` | `dc-reset [service...]` | `dc-reset`<br>`DC_FORCE=1 dc-reset`<br>`DC_NO_BACKUP=1 dc-reset mariadb` | Dump all databases to `backups/`, then `docker compose down -v` and `up -d`. Deletes every volume in the shared project. Asks first unless `DC_FORCE=1`. Skip the dump with `DC_NO_BACKUP=1`. A failed dump aborts. |
| `garc` | `garc <ProjectName> [path...]` | `garc MyApp`<br>`garc AliasOnly alias`<br>`GARC_OUT=/mnt/c/Users/You/Desktop garc MyApp` | `git archive` of `HEAD` to `./<ProjectName>.zip`. Override the folder with `GARC_OUT`. |
| `gout` | `gout <outdir> <ProjectName> [path...]` | `gout ../backups MyApp`<br>`gout /mnt/d/Backups MyApp` | Same as `garc`, with the output directory set for that call. |
| `gar_one` | `gar_one <ProjectName> [path...]` | `gar_one MyApp`<br>`gar_one AttendancePUSHCommunication` | `git archive` into the OneDrive `wsl_project` folder. Override the folder with `GAR_ONE_DIR`. |
| `ide-update` | `ide-update` | `ide-update` | From a Laravel project root: remove `vendor/_laravel_idea` and run `composer dump-autoload`. |

Internal helpers (`_dc_mysql_project`, `_dc_mysql_root_pass`, `_dc_mysql_exec`, `_dc_mysql_scalar`) are not meant to be called directly.

## Aliases

### Shell

| Alias | Usage | Command |
|---|---|---|
| `sb` | `sb` | `source ~/.bashrc` |
| `cls` | `cls` | `clear` |
| `ll` | `ll` | `ls -lah` |
| `la` | `la` | `ls -A` |
| `l` | `l` | `ls -CF` |
| `..` | `..` | `cd ..` |
| `...` | `...` | `cd ../..` |
| `myip` | `myip` | `hostname -I` |
| `os-v` | `os-v` | `lsb_release -a` |
| `ports` | `ports` | `ss -tulnp` |
| `all-apps` | `all-apps` | `apt-mark showmanual` |
| `p2kill` | `p2kill :8080` | Find a listener. Does not kill. |
| `fphp` | `fphp artisan ...` | PHP via FrankenPHP |
| `treel` | `treel 2` | `tree -L` |

### Git and Node

| Alias | Usage | Command |
|---|---|---|
| `gs` | `gs` | `git status` |
| `ga` | `ga` | `git add .` |
| `gc` | `gc "message"` | `git commit -m` |
| `gp` | `gp` | `git push` |
| `gl` | `gl` | `git pull` |
| `greset1` | `greset1` | Soft-reset the last commit; changes stay staged |
| `dev` | `dev` | `npm run dev` |
| `build` | `build` | `npm run build` |

### Docker

| Alias | Usage | Command |
|---|---|---|
| `d-ps` | `d-ps` | Running containers |
| `d-psa` | `d-psa` | All containers |
| `d-images` | `d-images` | Local images |
| `d-inspect` | `d-inspect <name>` | Full JSON for a container, image, network, or volume |
| `d-logs` | `d-logs <container>` | Follow logs |
| `d-logs-n` | `d-logs-n <container>` | Follow logs, last 100 lines |
| `d-history` | `d-history <image>` | Image layers |
| `d-port` | `d-port <container>` | Port mappings |
| `d-top` | `d-top` | Live CPU, memory, and network. Ctrl+C to stop |
| `d-prune` | `d-prune` | Remove unused containers, images, networks, and volumes |
| `d-prune-containers` | `d-prune-containers` | Stopped containers |
| `d-prune-images` | `d-prune-images` | Unused images |
| `d-prune-volumes` | `d-prune-volumes` | Unused volumes. Deletes their data |
| `d-prune-networks` | `d-prune-networks` | Unused networks |
| `dn-ls` | `dn-ls` | List networks |
| `dn-inspect` | `dn-inspect <net>` | Inspect one network |
| `dn-create` | `dn-create <name>` | Create a bridge network |
| `dn-prune` | `dn-prune` | Remove unused networks |
| `dv-ls` | `dv-ls` | List volumes |
| `dv-inspect` | `dv-inspect <vol>` | Inspect one volume |
| `dv-create` | `dv-create <name>` | Create a named volume |
| `dv-prune` | `dv-prune` | Remove unused volumes. Deletes their data |

### Compose

These use the compose file in the current directory.

| Alias | Usage | Command |
|---|---|---|
| `dc-u` | `dc-u` | `up -d` |
| `dc-ub` | `dc-ub` | `up -d --build` |
| `dc-d` | `dc-d` | `down`. Volumes stay |
| `dc-dv` | `dc-dv` | `down -v`. Deletes compose volumes |
| `dc-do` | `dc-do` | `down -v --remove-orphans` |
| `dc-re` | `dc-re` | Restart. No rebuild |
| `dc-l` | `dc-l` | Follow all logs |
| `dc-l100` | `dc-l100` | Follow all logs, last 100 lines |
| `dc-e` | `dc-e <service> bash` | Exec into a service |
| `dc-ps` | `dc-ps` | Project status |
| `dc-stop` | `dc-stop` | Stop without removing |
| `dc-start` | `dc-start` | Start stopped containers |
| `dc-pull` | `dc-pull` | Pull newer images |
| `dc-config` | `dc-config` | Print the resolved compose file |
| `dc-dbu` | `dc-dbu` | `down -v`, then `up -d --build` |
| `dc-db` | `dc-db` | Same, plus remove orphans |
| `dc-upd` | `dc-upd` | `up -d --force-recreate` |
| `dc-b` | `dc-b` | Build with no cache |
| `dc-bup` | `dc-bup` | No-cache build, then `up -d` |
| `dc-down-all` | `dc-down-all` | Remove containers, volumes, project images, and orphans |

### Laravel

`a` is `php artisan`, so `a migrate` is the same as `php artisan migrate`.

| Alias | Usage | Command |
|---|---|---|
| `a` | `a <cmd>` | `php artisan` |
| `crd` | `crd` | `composer run dev` |
| `pad` | `pad` | `php artisan dev` |
| `ln` | `ln myapp` | `laravel new` |
| `rc` / `rcl` / `rl` | `rl` | `route:cache` / `route:clear` / `route:list` |
| `sl` / `sul` | `sl` | `storage:link` / `storage:unlink` |
| `sp` | `sp` | `stub:publish` |
| `sail` | `sail up` | Project `sail`, or `vendor/bin/sail` |
| `sa` / `si` / `spub` | `si` | `sail:add` / `sail:install` / `sail:publish` |
| `add-sail` | `add-sail` | `composer require laravel/sail --dev` |
| `install-sail` | `install-sail` | `php artisan sail:install` |
| `qc` / `qf` / `qfl` / `qfg` | `qf` | `queue:clear` / `failed` / `flush` / `forget` |
| `ql` / `qm` / `qw` | `qw` | `queue:listen` / `monitor` / `work` |
| `qpb` / `qpf` | `qpf` | `queue:prune-batches` / `prune-failed` |
| `qr` / `qrt` / `qrb` | `qrt` | `queue:restart` / `retry` / `retry-batch` |
| `ideu` | `ideu` | Remove Laravel Idea helpers and dump autoload |

### Make, migrate, database, Livewire

| Alias | Usage | Command |
|---|---|---|
| `amc` | `amc Name` | `make:class` |
| `amcmd` | `amcmd Name` | `make:command` |
| `amcmp` | `amcmp Name` | `make:component` |
| `amctl` | `amctl Name` | `make:controller` |
| `amen` | `amen Name` | `make:enum` |
| `amev` | `amev Name` | `make:event` |
| `amf` | `amf Name` | `make:factory` |
| `ami` | `ami Name` | `make:interface` |
| `amj` | `amj Name` | `make:job` |
| `aml` | `aml Name` | `make:listener` |
| `amm` | `amm Name` | `make:mail` |
| `ammw` | `ammw Name` | `make:middleware` |
| `ammg` | `ammg name` | `make:migration` |
| `ammo` | `ammo Name` | `make:model` |
| `amnt` | `amnt Name` | `make:notification` |
| `amntt` | `amntt` | `make:notifications-table` |
| `amob` | `amob Name` | `make:observer` |
| `amp` | `amp Name` | `make:policy` |
| `ampr` | `ampr Name` | `make:provider` |
| `amqb` | `amqb` | `make:queue-batches-table` |
| `amqf` | `amqf` | `make:queue-failed-table` |
| `amqt` | `amqt` | `make:queue-table` |
| `amr` | `amr Name` | `make:request` |
| `amrs` | `amrs Name` | `make:resource` |
| `amrule` | `amrule Name` | `make:rule` |
| `amsc` | `amsc Name` | `make:scope` |
| `amsd` | `amsd Name` | `make:seeder` |
| `amst` | `amst` | `make:session-table` |
| `amt` | `amt Name` | `make:test` |
| `amtr` | `amtr Name` | `make:trait` |
| `amv` | `amv name` | `make:view` |
| `mg` | `mg` | `migrate` |
| `mgf` | `mgf` | `migrate:fresh` |
| `mgi` | `mgi` | `migrate:install` |
| `mgr` | `mgr` | `migrate:refresh` |
| `mgreset` | `mgreset` | `migrate:reset` |
| `mgb` | `mgb` | `migrate:rollback` |
| `mgs` | `mgs` | `migrate:status` |
| `dbm` | `dbm` | `db:monitor` |
| `dbs` | `dbs` | `db:seed` |
| `dbsh` | `dbsh` | `db:show` |
| `dbt` | `dbt users` | `db:table` |
| `dbw` | `dbw` | `db:wipe` |
| `lwa` | `lwa` | `livewire:attribute` |
| `lwc` | `lwc` | `livewire:config` |
| `lwcv` | `lwcv` | `livewire:convert` |
| `lwf` | `lwf` | `livewire:form` |
| `lwl` | `lwl` | `livewire:layout` |
| `lws` | `lws` | `livewire:stubs` |
| `mlw` | `mlw Name` | `make:livewire` |
| `mlwp` | `mlwp Dashboard` | `make:livewire pages::` |
| `pstress` | `pstress` | `./vendor/bin/pest stress` |
