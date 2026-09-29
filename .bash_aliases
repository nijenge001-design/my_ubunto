cat > ~/.bash_aliases <<'EOF'
#!/bin/bash
# Docker, Laravel & Dev Aliases
# source ~/.bashrc  (or source this file)

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
alias os-v='lsb_release -a'          # Ubuntu version
alias ports='netstat -tulnp'
alias all-apps='apt-mark showmanual'
alias p2kill='sudo ss -tulpn | grep'
alias fphp='/usr/bin/frankenphp php-cli'

# ============================================
# GIT
# ============================================
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias greset1="git reset --soft HEAD~1"
alias greset="git update-ref -d HEAD"

# ============================================
# NODE / FRONTEND
# ============================================
alias dev='npm run dev'
alias build='npm run build'

# ============================================
# DOCKER – BASIC
# ============================================
alias d-ps='docker ps'
alias d-psa='docker ps -a'
alias d-images='docker images'
alias d-inspect='docker inspect'
alias d-logs='docker logs -f'
alias d-logs-n='docker logs -f --tail=100'
alias d-history='docker history'
alias d-port='docker port'
alias d-top='docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"'

# ============================================
# DOCKER – PRUNE / CLEANUP
# ============================================
alias d-prune='docker system prune -af --volumes'   # CAUTION: removes everything unused
alias d-prune-containers='docker container prune -f'
alias d-prune-images='docker image prune -af'
alias d-prune-volumes='docker volume prune -f'
alias d-prune-networks='docker network prune -f'

# ============================================
# DOCKER – NETWORKS
# ============================================
alias dn-ls='docker network ls'
alias dn-inspect='docker network inspect'
alias dn-create='docker network create'
alias dn-prune='docker network prune -f'

# ============================================
# DOCKER – VOLUMES
# ============================================
alias dv-ls='docker volume ls'
alias dv-inspect='docker volume inspect'
alias dv-prune='docker volume prune -f'
alias dv-create='docker volume create'

# ============================================
# DOCKER COMPOSE – BASIC
# ============================================
alias dc-u='docker compose up -d'
alias dc-ub='docker compose up -d --build'
alias dc-d='docker compose down'
alias dc-dv='docker compose down -v'
alias dc-do='docker compose down -v --remove-orphans'
alias dc-re='docker compose restart'
alias dc-l='docker compose logs -f'
alias dc-l100='docker compose logs -f --tail=100'
alias dc-e='docker compose exec'
alias dc-ps='docker compose ps'
alias dc-stop='docker compose stop'
alias dc-start='docker compose start'
alias dc-pull='docker compose pull'
alias dc-config='docker compose config'

# ============================================
# DOCKER COMPOSE – COMBINED / ADVANCED
# ============================================
alias dc-dbu='docker compose down -v && docker compose up -d --build'
alias dc-db='docker compose down -v --remove-orphans && docker compose up -d --build'
alias dc-upd='docker compose up -d --force-recreate'
alias dc-b='docker compose build --no-cache'
alias dc-bup='docker compose build --no-cache && docker compose up -d'
alias dc-down-all='docker compose down --rmi all -v --remove-orphans'

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
alias sa='a sail:add'
alias si='a sail:install'
alias spub='a sail:publish'

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
# LARAVEL – MAKE (m*)
# ============================================
alias mc='a make:class'
alias mcmd='a make:command'
alias mcmp='a make:component'
alias mctl='a make:controller'
alias men='a make:enum'
alias mev='a make:event'
alias mf='a make:factory'
alias mi='a make:interface'
alias mj='a make:job'
alias ml='a make:listener'
alias mm='a make:mail'
alias mmw='a make:middleware'
alias mmg='a make:migration'
alias mmo='sleep 2; php artisan make:model'
alias mnt='a make:notification'
alias mntt='a make:notifications-table'
alias mob='a make:observer'
alias mp='a make:policy'
alias mpr='a make:provider'
alias mqb='a make:queue-batches-table'
alias mqf='a make:queue-failed-table'
alias mqt='a make:queue-table'
alias mr='a make:request'
alias mrs='a make:resource'
alias mrule='a make:rule'
alias msc='a make:scope'
alias msd='a make:seeder'
alias mst='a make:session-table'
alias mt='a make:test'
alias mtr='a make:trait'
alias mv='a make:view'

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
# HELPER FUNCTIONS
# ============================================

# Clean up everything except volumes (safer than full prune)
docker-clean-safe() {
    echo "Cleaning containers, images, and networks..."
    docker container prune -f
    docker image prune -af
    docker network prune -f
    echo "Done! Volumes were preserved."
}

# Show resource usage summary
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

# Enter a running container
docker-shell() {
    if [ -z "$1" ]; then
        echo "Usage: docker-shell <container-name> [shell=/bin/bash]"
        return 1
    fi
    local shell="${2:-/bin/bash}"
    docker exec -it "$1" "$shell"
}

# Start specific service with rebuild
dc-service-up() {
    if [ -z "$1" ]; then
        echo "Usage: dc-service-up <service-name>"
        return 1
    fi
    docker compose up -d --build "$1"
}

# Restart specific service
dc-service-re() {
    if [ -z "$1" ]; then
        echo "Usage: dc-service-re <service-name>"
        return 1
    fi
    docker compose restart "$1"
}

# Show logs for specific service
dc-service-logs() {
    if [ -z "$1" ]; then
        echo "Usage: dc-service-logs <service-name> [lines=50]"
        return 1
    fi
    local lines="${2:-50}"
    docker compose logs -f --tail="$lines" "$1"
}

# Exec into specific service
dc-service-shell() {
    if [ -z "$1" ]; then
        echo "Usage: dc-service-shell <service-name> [shell=/bin/bash]"
        return 1
    fi
    local shell="${2:-/bin/bash}"
    docker compose exec "$1" "$shell"
}

# Show logs with timestamp
docker-logs-with-time() {
    if [ -z "$1" ]; then
        echo "Usage: docker-logs-with-time <container-name> [lines=50]"
        return 1
    fi
    local lines="${2:-50}"
    docker logs -f --tail="$lines" -t "$1"
}

# Create MySQL database + user inside the 'mysql' container
# Usage:
#   dc-mkdb myapp
#   dc-mkdb myapp myuser
#   dc-mkdb myapp myuser mypass
dc-mkdb() {
  # usage: dc-mkdb <database> [username] [password]
  # runs against ~/docker/shared-services from any directory
  local project="${DC_SHARED_SERVICES:-$HOME/docker/shared-services}"
  local db="$1" user="${2:-$1}" pass="${3:-$user}" service="${4:-mysql}"

  if [ -z "$db" ]; then
    echo "usage: dc-mkdb <database> [username] [password] [service]" >&2
    echo "  project: $project" >&2
    return 1
  fi

  (
    cd "$project" || { echo "error: project not found: $project" >&2; exit 1; }

    local root_pass="${MYSQL_ROOT_PASSWORD:-}"
    if [ -z "$root_pass" ] && [ -f .env ]; then
      root_pass="$(
        grep -E '^[[:space:]]*MYSQL_ROOT_PASSWORD=' .env \
          | tail -n1 \
          | sed -E 's/^[[:space:]]*MYSQL_ROOT_PASSWORD=//; s/^["'\'']//; s/["'\'']$//'
      )"
    fi

    if [ -z "$root_pass" ]; then
      echo "error: MYSQL_ROOT_PASSWORD not set and not found in $project/.env" >&2
      exit 1
    fi

    if ! docker compose ps --status running --services 2>/dev/null | grep -qx "$service"; then
      echo "error: compose service '$service' is not running in $project" >&2
      exit 1
    fi

    if ! docker compose exec -T -e MYSQL_PWD="$root_pass" "$service" \
        mysql -uroot -e "SELECT 1" >/dev/null; then
      echo "error: root login failed for service '$service'" >&2
      exit 1
    fi

    if ! docker compose exec -T -e MYSQL_PWD="$root_pass" "$service" mysql -uroot -e \
      "CREATE DATABASE IF NOT EXISTS \`${db}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
       CREATE USER IF NOT EXISTS '${user}'@'%' IDENTIFIED BY '${pass}';
       GRANT ALL PRIVILEGES ON \`${db}\`.* TO '${user}'@'%';
       FLUSH PRIVILEGES;"; then
      echo "error: failed to create database/user '${db}'" >&2
      exit 1
    fi

    echo "created db=${db} user=${user} service=${service} project=${project}"
  )
}

# ===== Git archive helpers =====

# Create a git archive zip for a project
# Usage: garc <ProjectName> [path...]
# Default output: ./<ProjectName>.zip
# Override folder with GARC_OUT env var.
garc() {
    local project="${1:?Usage: garc <ProjectName> [path...]}"
    shift
    local out_dir="${GARC_OUT:-.}"
    mkdir -p "$out_dir"
    local out="${out_dir%/}/${project}.zip"
    git archive -o "$out" HEAD "$@" || { echo "git archive failed"; return 1; }
    echo "Created: $out"
    ls -lh "$out"
}

# Create a git archive zip to OneDrive wsl_project folder
# Usage: gar_one <ProjectName> [path...]
gar_one() {
    local project="${1:?Usage: gar_one <ProjectName> [path...]}"
    shift
    local out_dir="/mnt/c/Users/SGL/OneDrive - Contoso/wsl_project"
    local out="${out_dir%/}/${project}.zip"
    mkdir -p "$(dirname "$out")" || {
        echo "Failed to create output directory:"
        echo "  $(dirname "$out")"
        return 1
    }
    git archive -o "$out" HEAD "$@" || {
        echo "git archive failed"
        return 1
    }
    echo "Created: $out"
    ls -lh "$out"
}

# Shortcut: set output dir then run garc
# Usage: gout <outdir> <ProjectName> [path...]
gout() {
    local out_dir="${1:?Usage: gout <outdir> <ProjectName> [path...]}"
    shift
    GARC_OUT="$out_dir" garc "$@"
}

# ============================================
# LARAVEL – IDE / LARAVEL IDEA
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
    echo "Laravel Idea helper directory:"
    if [ -d "vendor/_laravel_idea" ]; then
        echo "  vendor/_laravel_idea exists"
    else
        echo "  vendor/_laravel_idea will be regenerated by PhpStorm."
    fi
    echo "Done."
}

# ============================================
# USAGE EXAMPLES (COMMENTED)
# ============================================
#
# ── GENERAL / SHELL ──────────────────────────────────────────────
# sb                          # reload ~/.bashrc
# cls                         # clear screen
# ll                          # long list with hidden files
# la / l                      # list almost-all / column format
# ..  / ...                   # go up 1 / 2 directories
# myip                        # show local IPs
# os-v                        # show Ubuntu version
# ports                       # show listening ports
# all-apps                    # list manually installed packages
# p2kill :8080                # find process listening on port
# fphp artisan ...            # run PHP via FrankenPHP
#
# ── GIT ──────────────────────────────────────────────────────────
# gs                          # git status
# ga                          # git add .
# gc "message"                # git commit -m "message"
# gp / gl                     # push / pull
# greset1                     # soft reset last commit (keeps staged)
# greset                      # delete HEAD ref (DANGEROUS)
#
# ── NODE / FRONTEND ──────────────────────────────────────────────
# dev                         # npm run dev
# build                       # npm run build
#
# ── DOCKER BASIC ─────────────────────────────────────────────────
# d-ps / d-psa                # running / all containers
# d-images                    # list images
# d-inspect <container>       # detailed info
# d-logs <container>          # follow logs
# d-logs-n <container>        # follow last 100 lines
# d-history <image>           # image layers
# d-port <container>          # port mappings
# d-top                       # live CPU / mem / net table
#
# ── DOCKER PRUNE ─────────────────────────────────────────────────
# d-prune                     # full aggressive cleanup (CAUTION)
# d-prune-containers          # only stopped containers
# d-prune-images              # unused images
# d-prune-volumes             # unused volumes
# d-prune-networks            # unused networks
#
# ── DOCKER NETWORKS / VOLUMES ────────────────────────────────────
# dn-ls / dn-inspect <net> / dn-create <name> / dn-prune
# dv-ls / dv-inspect <vol> / dv-create <name> / dv-prune
#
# ── DOCKER COMPOSE BASIC ─────────────────────────────────────────
# dc-u                        # up -d
# dc-ub                       # up -d --build
# dc-d                        # down
# dc-dv                       # down -v
# dc-do                       # down -v --remove-orphans
# dc-re                       # restart
# dc-l                        # logs -f (all)
# dc-l100                     # logs -f --tail=100
# dc-e <service> bash         # exec into service
# dc-ps                       # compose ps
# dc-stop / dc-start          # stop / start without removing
# dc-pull                     # pull latest images
# dc-config                   # validate compose file
#
# ── DOCKER COMPOSE ADVANCED ──────────────────────────────────────
# dc-dbu                      # down -v && up -d --build
# dc-db                       # full clean + rebuild (recommended)
# dc-upd                      # force-recreate
# dc-b                        # build --no-cache
# dc-bup                      # no-cache build + up -d
# dc-down-all                 # remove containers, volumes, images, orphans
#
# ── LARAVEL CORE ─────────────────────────────────────────────────
# a <cmd>                     # php artisan <cmd>
# crd                         # composer run dev
# pad                         # php artisan dev
# ln myapp                    # laravel new myapp
#
# ── ROUTES / STORAGE / STUBS / SAIL ──────────────────────────────
# rc / rcl / rl               # route:cache / clear / list
# sl / sul                    # storage:link / unlink
# sp                          # stub:publish
# sa / si / spub              # sail:add / install / publish
#
# ── QUEUE ────────────────────────────────────────────────────────
# qc / qf / qfl / qfg         # clear / failed / flush / forget
# ql / qm / qw                # listen / monitor / work
# qpb / qpf                   # prune-batches / prune-failed
# qr / qrt / qrb              # restart / retry / retry-batch
#
# ── MAKE (m*) ────────────────────────────────────────────────────
# mc / mcmd / mcmp / mctl     # class / command / component / controller
# men / mev / mf / mi / mj    # enum / event / factory / interface / job
# ml / mm / mmw / mmg / mmo   # listener / mail / middleware / migration / model
# mnt / mntt / mob / mp       # notification / notifications-table / observer / policy
# mpr / mqb / mqf / mqt       # provider / queue-batches / queue-failed / queue-table
# mr / mrs / mrule / msc      # request / resource / rule / scope
# msd / mst / mt / mtr / mv   # seeder / session-table / test / trait / view
#
# ── MIGRATIONS (mg*) ─────────────────────────────────────────────
# mg / mgf / mgi / mgr        # migrate / fresh / install / refresh
# mgreset / mgb / mgs         # reset / rollback / status
#
# ── DATABASE (db*) ───────────────────────────────────────────────
# dbm / dbs / dbsh / dbt / dbw   # monitor / seed / show / table / wipe
#
# ── LIVEWIRE ─────────────────────────────────────────────────────
# lwa / lwc / lwcv / lwf      # attribute / config / convert / form
# lwl / lws                   # layout / stubs
# mlw <name>                  # make:livewire
# mlwp Dashboard              # make:livewire pages::Dashboard
# pstress                     # ./vendor/bin/pest stress
#
# ── HELPER FUNCTIONS ─────────────────────────────────────────────
#
# docker-clean-safe
#   Safe cleanup (containers + images + networks). Volumes kept.
#   Example:  docker-clean-safe
#
# docker-summary
#   Pretty overview of containers, images, volumes, networks.
#   Example:  docker-summary
#
# docker-shell <container> [shell]
#   Interactive shell inside a running container.
#   Examples:
#     docker-shell app
#     docker-shell app /bin/sh
#     docker-shell db bash
#
# dc-service-up <service>
#   Rebuild + start a single Compose service.
#   Example:  dc-service-up nginx
#
# dc-service-re <service>
#   Restart a single Compose service.
#   Example:  dc-service-re redis
#
# dc-service-logs <service> [lines]
#   Follow logs for one service (default 50 lines).
#   Examples:
#     dc-service-logs app
#     dc-service-logs db 200
#
# dc-service-shell <service> [shell]
#   Shell inside a Compose service.
#   Examples:
#     dc-service-shell app
#     dc-service-shell app sh
#
# docker-logs-with-time <container> [lines]
#   Follow container logs with timestamps.
#   Examples:
#     docker-logs-with-time nginx
#     docker-logs-with-time app 100
#
# dc-mkdb <database> [user] [pass]
#   Create database + user inside the 'mysql' container.
#   Examples:
#     dc-mkdb myapp
#     dc-mkdb myapp appuser
#     dc-mkdb myapp appuser secret
#
# garc <ProjectName> [path...]
#   Git archive → zip (default ./ProjectName.zip).
#   Override folder with GARC_OUT.
#   Examples:
#     garc MyApp
#     garc AliasOnly alias
#     GARC_OUT=/mnt/c/Users/You/Desktop garc MyApp
#
# gout <outdir> <ProjectName> [path...]
#   Set output dir then run garc.
#   Examples:
#     gout ../backups MyApp
#     gout /mnt/d/Backups MyApp
#
# gar_one <ProjectName> [path...]
#   Git archive straight to OneDrive wsl_project folder.
#   Examples:
#     gar_one MyApp
#     gar_one AttendancePUSHCommunication
#
# ideu / ide-update
#   Remove Laravel Idea helpers and regenerate Composer autoload.
#   Run from project root.
#
# ============================================
# END OF ALIASES
# ============================================

EOF
