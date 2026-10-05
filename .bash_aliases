cat > ~/.bash_aliases <<'EOF'
#!/bin/bash
# Docker, Laravel & Dev Aliases
# source ~/.bashrc   (or: source /path/to/this/file)
# ============================================
# GENERAL / SHELL
# ============================================
alias sb='source ~/.bashrc'
alias cls='clear'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias myip='hostname -I'
alias os-v='lsb_release -a'
alias ports='ss -tulnp'
alias all-apps='apt-mark showmanual'
alias p2kill='sudo ss -tulpn | grep'   # find listener; does not kill
alias fphp='/usr/bin/frankenphp php-cli'
alias treel='tree -L'

# ============================================
# GIT
# ============================================
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias greset1='git reset --soft HEAD~1'   # undo last commit, keep changes staged
# greset (delete HEAD ref) intentionally omitted — use greset1

# ============================================
# NODE / FRONTEND
# ============================================
alias dev='npm run dev'
alias build='npm run build'

# ============================================
# DOCKER – BASIC
# ============================================
alias d-ps='docker ps'                                          # running containers only
alias d-psa='docker ps -a'                                      # all containers, including stopped
alias d-images='docker images'                                  # local images
alias d-inspect='docker inspect'                                # full JSON for a container, image, network, or volume
alias d-logs='docker logs -f'                                   # follow a container's stdout/stderr
alias d-logs-n='docker logs -f --tail=100'                      # follow logs, start at the last 100 lines
alias d-history='docker history'                                # image layers and the command that created each
alias d-port='docker port'                                      # host-to-container port mappings
alias d-top='docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"'  # live CPU, memory, and network; Ctrl+C to stop

# ============================================
# DOCKER – PRUNE / CLEANUP
# ============================================
alias d-prune='docker system prune -af --volumes'               # CAUTION: unused containers, images, networks, and volumes
alias d-prune-containers='docker container prune -f'            # stopped containers only
alias d-prune-images='docker image prune -af'                   # images not used by any container
alias d-prune-volumes='docker volume prune -f'                  # unused volumes; data in them is deleted
alias d-prune-networks='docker network prune -f'                # networks with no connected container

# ============================================
# DOCKER – NETWORKS
# ============================================
alias dn-ls='docker network ls'                                 # list networks
alias dn-inspect='docker network inspect'                       # subnets, containers, and driver for one network
alias dn-create='docker network create'                         # create a bridge network
alias dn-prune='docker network prune -f'                        # remove unused networks

# ============================================
# DOCKER – VOLUMES
# ============================================
alias dv-ls='docker volume ls'                                  # list volumes
alias dv-inspect='docker volume inspect'                        # mount point and labels
alias dv-prune='docker volume prune -f'                         # remove unused volumes; deletes their data
alias dv-create='docker volume create'                          # create a named volume

# ============================================
# DOCKER COMPOSE – BASIC
# Uses compose.yaml in the current directory.
# ============================================
alias dc-u='docker compose up -d'                               # start services in the background; build only if image is missing
alias dc-ub='docker compose up -d --build'                      # rebuild images, then start
alias dc-d='docker compose down'                                # stop and remove containers and project network; volumes stay
alias dc-dv='docker compose down -v'                            # down, and delete volumes declared in the compose file
alias dc-do='docker compose down -v --remove-orphans'           # down -v, and remove containers no longer in the file
alias dc-re='docker compose restart'                            # restart running services; no rebuild
alias dc-l='docker compose logs -f'                             # follow logs for every service
alias dc-l100='docker compose logs -f --tail=100'               # follow logs, last 100 lines first
alias dc-e='docker compose exec'                                # run a command in a running service: dc-e app bash
alias dc-ps='docker compose ps'                                 # status of this project's services
alias dc-stop='docker compose stop'                             # stop without removing containers
alias dc-start='docker compose start'                           # start stopped containers without recreating them
alias dc-pull='docker compose pull'                             # pull newer images
alias dc-config='docker compose config'                         # print the resolved compose file; check before up

# ============================================
# DOCKER COMPOSE – COMBINED / ADVANCED
# ============================================
alias dc-dbu='docker compose down -v && docker compose up -d --build'                              # wipe compose volumes, rebuild, start
alias dc-db='docker compose down -v --remove-orphans && docker compose up -d --build'              # same, plus remove orphans
alias dc-upd='docker compose up -d --force-recreate'                                               # recreate containers even if config did not change
alias dc-b='docker compose build --no-cache'                                                        # build with no cache
alias dc-bup='docker compose build --no-cache && docker compose up -d'                             # no-cache build, then start
alias dc-down-all='docker compose down --rmi all -v --remove-orphans'                              # remove containers, volumes, project images, and orphans

# ============================================
# LARAVEL – CORE
# ============================================
alias a='php artisan'
alias crd='composer run dev'
alias pad='php artisan dev'
alias ln='laravel new'

# ============================================
# LARAVEL – ROUTES
# ============================================
alias rc='a route:cache'
alias rcl='a route:clear'
alias rl='a route:list'

# ============================================
# LARAVEL – STORAGE
# ============================================
alias sl='a storage:link'
alias sul='a storage:unlink'

# ============================================
# LARAVEL – STUBS & SAIL
# ============================================
alias sp='a stub:publish'
alias sail='sh $([ -f sail ] && echo sail || echo vendor/bin/sail)'
alias sa='a sail:add'
alias si='a sail:install'
alias spub='a sail:publish'
alias add-sail='composer require laravel/sail --dev'
alias install-sail='php artisan sail:install'

# ============================================
# LARAVEL – QUEUE
# ============================================
alias qc='a queue:clear'
alias qf='a queue:failed'
alias qfl='a queue:flush'
alias qfg='a queue:forget'
alias ql='a queue:listen'
alias qm='a queue:monitor'
alias qpb='a queue:prune-batches'
alias qpf='a queue:prune-failed'
alias qr='a queue:restart'
alias qrt='a queue:retry'
alias qrb='a queue:retry-batch'
alias qw='a queue:work'

# ============================================
# LARAVEL – MAKE (am*)
# ============================================
alias amc='a make:class'
alias amcmd='a make:command'
alias amcmp='a make:component'
alias amctl='a make:controller'
alias amen='a make:enum'
alias amev='a make:event'
alias amf='a make:factory'
alias ami='a make:interface'
alias amj='a make:job'
alias aml='a make:listener'
alias amm='a make:mail'
alias ammw='a make:middleware'
alias ammg='a make:migration'
alias ammo='a make:model'
alias amnt='a make:notification'
alias amntt='a make:notifications-table'
alias amob='a make:observer'
alias amp='a make:policy'
alias ampr='a make:provider'
alias amqb='a make:queue-batches-table'
alias amqf='a make:queue-failed-table'
alias amqt='a make:queue-table'
alias amr='a make:request'
alias amrs='a make:resource'
alias amrule='a make:rule'
alias amsc='a make:scope'
alias amsd='a make:seeder'
alias amst='a make:session-table'
alias amt='a make:test'
alias amtr='a make:trait'
alias amv='a make:view'

# ============================================
# LARAVEL – MIGRATIONS (mg*)
# ============================================
alias mg='a migrate'
alias mgf='a migrate:fresh'
alias mgi='a migrate:install'
alias mgr='a migrate:refresh'
alias mgreset='a migrate:reset'
alias mgb='a migrate:rollback'
alias mgs='a migrate:status'

# ============================================
# LARAVEL – DATABASE (db*)
# ============================================
alias dbm='a db:monitor'
alias dbs='a db:seed'
alias dbsh='a db:show'
alias dbt='a db:table'
alias dbw='a db:wipe'

# ============================================
# LIVEWIRE (lw*)
# ============================================
alias lwa='a livewire:attribute'
alias lwc='a livewire:config'
alias lwcv='a livewire:convert'
alias lwf='a livewire:form'
alias lwl='a livewire:layout'
alias lws='a livewire:stubs'
alias mlw='a make:livewire'
alias mlwp='a make:livewire pages::'
alias pstress='./vendor/bin/pest stress '

# ============================================
# HELPER FUNCTIONS – DOCKER
# ============================================
# Containers, images, and networks only. Volumes are kept.
docker-clean-safe() {
    echo "Cleaning containers, images, and networks..."
    docker container prune -f
    docker image prune -af
    docker network prune -f
    echo "Done. Volumes were preserved."
}

# Containers, images, volumes, and networks in one view.
docker-summary() {
    echo "=== CONTAINERS ==="
    docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
    echo -e "\n=== IMAGES ==="
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
    echo -e "\n=== VOLUMES ==="
    docker volume ls
    echo -e "\n=== NETWORKS ==="
    docker network ls
}

# Shell in a running container by name. Usage: docker-shell <container> [shell]
docker-shell() {
    if [ -z "$1" ]; then
        echo "Usage: docker-shell <container-name> [shell=/bin/bash]"
        return 1
    fi
    local shell="${2:-/bin/bash}"
    docker exec -it "$1" "$shell"
}

# Rebuild and start one compose service. Usage: dc-service-up <service>
dc-service-up() {
    if [ -z "$1" ]; then
        echo "Usage: dc-service-up <service-name>"
        return 1
    fi
    docker compose up -d --build "$1"
}

# Restart one compose service. No rebuild. Usage: dc-service-re <service>
dc-service-re() {
    if [ -z "$1" ]; then
        echo "Usage: dc-service-re <service-name>"
        return 1
    fi
    docker compose restart "$1"
}

# Follow one service's logs. Usage: dc-service-logs <service> [lines=50]
dc-service-logs() {
    if [ -z "$1" ]; then
        echo "Usage: dc-service-logs <service-name> [lines=50]"
        return 1
    fi
    local lines="${2:-50}"
    docker compose logs -f --tail="$lines" "$1"
}

# Shell in a compose service. Usage: dc-service-shell <service> [shell=/bin/bash]
dc-service-shell() {
    if [ -z "$1" ]; then
        echo "Usage: dc-service-shell <service-name> [shell=/bin/bash]"
        return 1
    fi
    local shell="${2:-/bin/bash}"
    docker compose exec "$1" "$shell"
}

# Follow container logs with timestamps. Usage: docker-logs-with-time <container> [lines=50]
docker-logs-with-time() {
    if [ -z "$1" ]; then
        echo "Usage: docker-logs-with-time <container-name> [lines=50]"
        return 1
    fi
    local lines="${2:-50}"
    docker logs -f --tail="$lines" -t "$1"
}

# ============================================
# HELPER FUNCTIONS – SHARED MYSQL (compose)
# All run against $DC_SHARED_SERVICES (default ~/docker/shared-services)
# from any directory. Service defaults to $DC_MYSQL_SERVICE (default mysql).
# Root password: $MYSQL_ROOT_PASSWORD, else MYSQL_ROOT_PASSWORD in project .env.
# ============================================
# Change to mariadb if that is the service name in the compose file.
export DC_MYSQL_SERVICE="${DC_MYSQL_SERVICE:-mysql}"
_dc_mysql_project() {
    printf '%s\n' "${DC_SHARED_SERVICES:-$HOME/docker/shared-services}"
}

_dc_mysql_root_pass() {
    local project="$1" root_pass="${MYSQL_ROOT_PASSWORD:-}"
    if [ -z "$root_pass" ] && [ -f "$project/.env" ]; then
        root_pass="$(
            grep -E '^[[:space:]]*MYSQL_ROOT_PASSWORD=' "$project/.env" \
                | tail -n1 \
                | sed -E 's/^[[:space:]]*MYSQL_ROOT_PASSWORD=//; s/^["'\'']//; s/["'\'']$//'
        )"
    fi
    printf '%s\n' "$root_pass"
}

# Run SQL as root. Prints mysql stderr on failure.
# Usage: _dc_mysql_exec <service> <sql>
_dc_mysql_exec() {
    local service="$1" sql="$2"
    local project root_pass
    project="$(_dc_mysql_project)"
    if [ ! -d "$project" ]; then
        echo "error: project not found: $project" >&2
        return 1
    fi
    root_pass="$(_dc_mysql_root_pass "$project")"
    if [ -z "$root_pass" ]; then
        echo "error: MYSQL_ROOT_PASSWORD not set and not found in $project/.env" >&2
        return 1
    fi
    (
        cd "$project" || exit 1
        if ! docker compose ps --status running --services 2>/dev/null | grep -qx "$service"; then
            echo "error: compose service '$service' is not running in $project" >&2
            exit 1
        fi
        if ! docker compose exec -T -e MYSQL_PWD="$root_pass" "$service" \
            mysql -uroot -e "SELECT 1" >/dev/null; then
            echo "error: root login failed for service '$service'" >&2
            exit 1
        fi
        docker compose exec -T -e MYSQL_PWD="$root_pass" "$service" mysql -uroot -e "$sql"
    )
}

# Scalar query. Usage: _dc_mysql_scalar <service> <sql>
_dc_mysql_scalar() {
    local service="$1" sql="$2"
    local project root_pass
    project="$(_dc_mysql_project)"
    root_pass="$(_dc_mysql_root_pass "$project")"
    (
        cd "$project" || exit 1
        docker compose exec -T -e MYSQL_PWD="$root_pass" "$service" \
            mysql -uroot -N -B -e "$sql" 2>/dev/null
    )
}

# Create a MySQL user only. No database, no grant.
# Usage: dc-mkuser <username> [password] [service]
dc-mkuser() {
    local user="$1" pass="${2:-$user}" service="${3:-$DC_MYSQL_SERVICE}"
    local project
    project="$(_dc_mysql_project)"
    if [ -z "$user" ]; then
        echo "usage: dc-mkuser <username> [password] [service]" >&2
        echo "  project: $project" >&2
        return 1
    fi
    _dc_mysql_exec "$service" \
        "CREATE USER IF NOT EXISTS '${user}'@'%' IDENTIFIED BY '${pass}';
         FLUSH PRIVILEGES;" \
        && echo "created user=${user} service=${service} project=${project}"
}

# Create a MySQL database only. No user, no grant. utf8mb4 / utf8mb4_unicode_ci.
# Usage: dc-mkdbonly <database> [service]
dc-mkdbonly() {
    local db="$1" service="${2:-$DC_MYSQL_SERVICE}"
    local project
    project="$(_dc_mysql_project)"
    if [ -z "$db" ]; then
        echo "usage: dc-mkdbonly <database> [service]" >&2
        echo "  project: $project" >&2
        return 1
    fi
    _dc_mysql_exec "$service" \
        "CREATE DATABASE IF NOT EXISTS \`${db}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" \
        && echo "created db=${db} service=${service} project=${project}"
}

# Create database + user + grant. User defaults to the database name, password to the user.
# Users are created as 'user'@'%'. Usage: dc-mkdb <database> [username] [password] [service]
dc-mkdb() {
    local db="$1" user="${2:-$1}" pass="${3:-$user}" service="${4:-$DC_MYSQL_SERVICE}"
    local project
    project="$(_dc_mysql_project)"
    if [ -z "$db" ]; then
        echo "usage: dc-mkdb <database> [username] [password] [service]" >&2
        echo "  project: $project" >&2
        return 1
    fi
    _dc_mysql_exec "$service" \
        "CREATE DATABASE IF NOT EXISTS \`${db}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
         CREATE USER IF NOT EXISTS '${user}'@'%' IDENTIFIED BY '${pass}';
         GRANT ALL PRIVILEGES ON \`${db}\`.* TO '${user}'@'%';
         FLUSH PRIVILEGES;" \
        && echo "created db=${db} user=${user} service=${service} project=${project}"
}

# Grant an existing user an existing database. Fails if either is missing.
# Usage: dc-adduser <database> [username] [service]
dc-adduser() {
    local db="$1" user="${2:-$1}" service="${3:-$DC_MYSQL_SERVICE}"
    local project user_exists db_exists
    project="$(_dc_mysql_project)"
    if [ -z "$db" ]; then
        echo "usage: dc-adduser <database> [username] [service]" >&2
        echo "  project: $project" >&2
        return 1
    fi
    user_exists="$(_dc_mysql_scalar "$service" "SELECT COUNT(*) FROM mysql.user WHERE user='${user}';")"
    db_exists="$(_dc_mysql_scalar "$service" "SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name='${db}';")"
    if [ "$user_exists" != "1" ]; then
        echo "error: user '${user}' does not exist (use dc-mkuser or dc-mkdb)" >&2
        return 1
    fi
    if [ "$db_exists" != "1" ]; then
        echo "error: database '${db}' does not exist (use dc-mkdb or dc-mkdbonly)" >&2
        return 1
    fi
    _dc_mysql_exec "$service" \
        "GRANT ALL PRIVILEGES ON \`${db}\`.* TO '${user}'@'%';
         FLUSH PRIVILEGES;" \
        && echo "granted db=${db} user=${user} service=${service} project=${project}"
}

# Drop a database and user. Asks first unless DC_FORCE=1.
# Usage: dc-rmdb <database> [username] [service]
dc-rmdb() {
    local db="$1" user="${2:-$1}" service="${3:-$DC_MYSQL_SERVICE}"
    local project reply
    project="$(_dc_mysql_project)"
    if [ -z "$db" ]; then
        echo "usage: dc-rmdb <database> [username] [service]" >&2
        echo "  project: $project" >&2
        return 1
    fi
    if [ "${DC_FORCE:-0}" != "1" ]; then
        printf "DROP database '%s' and user '%s'@'%%' in '%s'? [y/N] " "$db" "$user" "$service"
        read -r reply
        case "$reply" in
            [yY]|[yY][eE][sS]) ;;
            *) echo "aborted" >&2; return 1 ;;
        esac
    fi
    _dc_mysql_exec "$service" \
        "DROP DATABASE IF EXISTS \`${db}\`;
         DROP USER IF EXISTS '${user}'@'%';
         FLUSH PRIVILEGES;" \
        && echo "dropped db=${db} user=${user} service=${service} project=${project}"
}

# Recreate the stack AND drop its volumes: every database in it.
# Dumps everything to ./backups first unless DC_NO_BACKUP=1.
# Prompts unless DC_FORCE=1.
# Usage: dc-reset [service...]
dc-reset() {
    local project="${DC_SHARED_SERVICES:-$HOME/docker/shared-services}"
    local mysql_service="${DC_MYSQL_SERVICE:-mysql}"
    local services="$*"
    (
        cd "$project" || { echo "error: project not found: $project" >&2; exit 1; }
        if [ "${DC_FORCE:-0}" != "1" ]; then
            printf "This DELETES every volume in %s — every database and all of its data. Continue? [y/N] " "$project"
            read -r reply
            case "$reply" in
                [yY]|[yY][eE][sS]) ;;
                *) echo "aborted" >&2; exit 1 ;;
            esac
        fi
        local root_pass="${MYSQL_ROOT_PASSWORD:-}"
        if [ -z "$root_pass" ] && [ -f .env ]; then
            root_pass="$(
                grep -E '^[[:space:]]*MYSQL_ROOT_PASSWORD=' .env \
                    | tail -n1 \
                    | sed -E 's/^[[:space:]]*MYSQL_ROOT_PASSWORD=//; s/^["'\'']//; s/["'\'']$//'
            )"
        fi
        # A dump before the wipe. down -v has no undo. If the stack is not answering
        # there is nothing to dump — say so rather than pretending.
        local backup=""
        if [ "${DC_NO_BACKUP:-0}" != "1" ] && [ -n "$root_pass" ] \
            && docker compose exec -T -e MYSQL_PWD="$root_pass" "$mysql_service" \
                mysql -uroot -e "SELECT 1" >/dev/null 2>&1; then
            mkdir -p backups
            backup="backups/all-databases-$(date +%Y%m%d-%H%M%S).sql"
            if docker compose exec -T -e MYSQL_PWD="$root_pass" "$mysql_service" \
                mysqldump --all-databases --single-transaction --routines --events -uroot \
                > "$backup" 2>/dev/null; then
                echo "backed up to $backup"
            else
                echo "warning: the backup failed — fix that, or set DC_NO_BACKUP=1 to reset without one" >&2
                exit 1
            fi
        else
            echo "note: no backup taken (the stack is not answering, or DC_NO_BACKUP=1)" >&2
        fi
        # shellcheck disable=SC2086
        docker compose down -v $services || exit 1
        # shellcheck disable=SC2086
        docker compose up -d $services || exit 1
        if [ -z "$root_pass" ]; then
            echo "reset — MYSQL_ROOT_PASSWORD is not set, so the database report is skipped" >&2
            return 0
        fi
        local tries=0
        until docker compose exec -T -e MYSQL_PWD="$root_pass" "$mysql_service" \
            mysql -uroot -e "SELECT 1" >/dev/null 2>&1; do
            tries=$((tries + 1))
            if [ "$tries" -ge 60 ]; then
                echo "warning: $mysql_service did not answer within 60s — a fresh volume means it is initialising" >&2
                return 1
            fi
            sleep 1
        done
        echo "databases now:"
        docker compose exec -T -e MYSQL_PWD="$root_pass" "$mysql_service" mysql -uroot -N -B -e "
            SELECT s.schema_name, COUNT(t.table_name)
              FROM information_schema.schemata s
              LEFT JOIN information_schema.tables t ON t.table_schema = s.schema_name
             WHERE s.schema_name NOT IN ('mysql', 'information_schema', 'performance_schema', 'sys')
             GROUP BY s.schema_name
             ORDER BY s.schema_name;" | sed 's/^/  /'
        echo "volumes were removed — the databases are gone and must be created again"
        if [ -n "$backup" ]; then
            echo "restore with:"
            echo "  cd $project"
            echo "  docker compose exec -T -e MYSQL_PWD=\"\$MYSQL_ROOT_PASSWORD\" $mysql_service mysql -uroot < $backup"
        fi
    )
}

# ============================================
# GIT ARCHIVE HELPERS
# ============================================
# Usage: garc <ProjectName> [path...]
# Default output: ./<ProjectName>.zip
# Override folder with GARC_OUT.
garc() {
    local project="${1:?Usage: garc <ProjectName> [path...]}"
    shift
    local out_dir="${GARC_OUT:-.}"
    mkdir -p "$out_dir" || return 1
    local out="${out_dir%/}/${project}.zip"
    git archive -o "$out" HEAD "$@" || { echo "git archive failed"; return 1; }
    echo "Created: $out"
    ls -lh "$out"
}

# Usage: gar_one <ProjectName> [path...]
# Writes to OneDrive wsl_project. Override with GAR_ONE_DIR.
gar_one() {
    local project="${1:?Usage: gar_one <ProjectName> [path...]}"
    shift
    local out_dir="${GAR_ONE_DIR:-/mnt/c/Users/SGL/OneDrive - Contoso/wsl_project}"
    local out="${out_dir%/}/${project}.zip"
    mkdir -p "$(dirname "$out")" || {
        echo "Failed to create output directory:"
        echo "  $(dirname "$out")"
        return 1
    }
    git archive -o "$out" HEAD "$@" || { echo "git archive failed"; return 1; }
    echo "Created: $out"
    ls -lh "$out"
}

# Usage: gout <outdir> <ProjectName> [path...]
gout() {
    local out_dir="${1:?Usage: gout <outdir> <ProjectName> [path...]}"
    shift
    GARC_OUT="$out_dir" garc "$@"
}

# ============================================
# LARAVEL IDEA
# ============================================
alias ideu='rm -rf vendor/_laravel_idea && composer dump-autoload'

ide-update() {
    echo "=== Updating Laravel Idea helper code ==="
    if [ ! -f "composer.json" ]; then
        echo "Error: composer.json not found."
        echo "Run this command from a Laravel project directory."
        return 1
    fi
    echo "Removing Laravel Idea generated helpers..."
    rm -rf vendor/_laravel_idea
    echo "Regenerating Composer autoload..."
    composer dump-autoload
    if [ -d "vendor/_laravel_idea" ]; then
        echo "Laravel Idea helper directory: vendor/_laravel_idea exists"
    else
        echo "vendor/_laravel_idea will be regenerated by PhpStorm."
    fi
    echo "Done."
}

# ============================================
# USAGE
# ============================================
#
# GENERAL:  sb  cls  ll  la  l  ..  ...  myip  os-v  ports  all-apps
#           p2kill :8080          # find process on port (does not kill)
#           fphp artisan ...      # PHP via FrankenPHP
#           treel 2               # tree -L 2
#
# GIT:      gs  ga  gc "msg"  gp  gl  greset1
#
# NODE:     dev  build
#
# DOCKER:   d-ps  d-psa  d-images  d-inspect <c>  d-logs <c>  d-logs-n <c>
#           d-history <img>  d-port <c>  d-top
#           d-prune  d-prune-containers  d-prune-images  d-prune-volumes  d-prune-networks
#           dn-ls  dn-inspect <net>  dn-create <name>  dn-prune
#           dv-ls  dv-inspect <vol>  dv-create <name>  dv-prune
#
# COMPOSE:  dc-u  dc-ub  dc-d  dc-dv  dc-do  dc-re  dc-l  dc-l100
#           dc-e <svc> bash  dc-ps  dc-stop  dc-start  dc-pull  dc-config
#           dc-dbu  dc-db  dc-upd  dc-b  dc-bup  dc-down-all
#
# LARAVEL:  a <cmd>  crd  pad  ln myapp
#           rc  rcl  rl  sl  sul  sp  sa  si  spub
#           qc  qf  qfl  qfg  ql  qm  qw  qpb  qpf  qr  qrt  qrb
#
# MAKE:     amc amcmd amcmp amctl amen amev amf ami amj aml amm ammw ammg ammo
#           amnt amntt amob amp ampr amqb amqf amqt amr amrs amrule amsc
#           amsd amst amt amtr amv
#
# MIGRATE:  mg  mgf  mgi  mgr  mgreset  mgb  mgs
# DATABASE: dbm  dbs  dbsh  dbt  dbw
# LIVEWIRE: lwa lwc lwcv lwf lwl lws  mlw <name>  mlwp Dashboard  pstress
#
# FUNCTIONS:
#   docker-clean-safe
#   docker-summary
#   docker-shell <container> [shell]
#   dc-service-up <service>
#   dc-service-re <service>
#   dc-service-logs <service> [lines]
#   dc-service-shell <service> [shell]
#   docker-logs-with-time <container> [lines]
#   dc-mkuser <username> [password] [service]
#   dc-mkdbonly <database> [service]
#   dc-mkdb <database> [user] [pass] [service]
#   dc-adduser <database> [user] [service]
#   dc-rmdb <database> [user] [service]     # DC_FORCE=1 skips prompt
#   dc-reset [service...]                   # down -v && up -d; dumps ./backups first
#                                           # DC_FORCE=1 skips prompt, DC_NO_BACKUP=1 skips dump
#   garc <ProjectName> [path...]            # GARC_OUT overrides folder
#   gout <outdir> <ProjectName> [path...]
#   gar_one <ProjectName> [path...]         # GAR_ONE_DIR overrides OneDrive path
#   ideu / ide-update
#
# ============================================
# END OF ALIASES
# ============================================

EOF
