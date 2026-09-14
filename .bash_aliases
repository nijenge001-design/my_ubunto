cat > ~/.bash_aliases <<'EOF'
# Cleaned `.bash_aliases`

# Copy **everything** inside the code block below into `~/.bash_aliases` (replace the whole file).


#!/bin/bash
# Docker, Laravel & Dev Aliases
# source ~/.bashrc  (or source this file)
# ============================================

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
alias ports='netstat -tulnp'
alias all-apps='apt-mark showmanual'
alias p2kill='sudo ss -tulpn | grep'

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
alias d-ps='docker ps'                                   # List running containers
alias d-psa='docker ps -a'                               # List all containers
alias d-images='docker images'                           # List all images
alias d-inspect='docker inspect'                         # Show detailed container info
alias d-logs='docker logs -f'                            # Follow container logs
alias d-logs-n='docker logs -f --tail=100'               # Follow last 100 lines
alias d-history='docker history'                         # Show image history
alias d-port='docker port'                               # List port mappings
alias d-top='docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"'

# ============================================
# DOCKER – PRUNE / CLEANUP
# ============================================
alias d-prune='docker system prune -af --volumes'        # Remove all unused data (CAUTION!)
alias d-prune-containers='docker container prune -f'     # Remove stopped containers
alias d-prune-images='docker image prune -af'            # Remove unused images
alias d-prune-volumes='docker volume prune -f'           # Remove unused volumes
alias d-prune-networks='docker network prune -f'         # Remove unused networks

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
alias dc-u='docker compose up -d'                        # Start containers in background
alias dc-ub='docker compose up -d --build'               # Build and start containers
alias dc-d='docker compose down'                         # Stop and remove containers
alias dc-dv='docker compose down -v'                     # Stop + remove containers & volumes
alias dc-do='docker compose down -v --remove-orphans'    # Full cleanup (containers, volumes, orphans)
alias dc-re='docker compose restart'                     # Restart all containers
alias dc-l='docker compose logs -f'                      # Follow logs from all containers
alias dc-l100='docker compose logs -f --tail=100'        # Follow last 100 lines of logs
alias dc-e='docker compose exec'                         # Execute command in running container
alias dc-ps='docker compose ps'                          # List containers with status
alias dc-stop='docker compose stop'                      # Stop containers without removing
alias dc-start='docker compose start'                    # Start stopped containers
alias dc-pull='docker compose pull'                      # Pull latest images
alias dc-config='docker compose config'                  # Validate and view compose file

# ============================================
# DOCKER COMPOSE – COMBINED / ADVANCED
# ============================================
alias dc-dbu='docker compose down -v && docker compose up -d --build'                    # Clean rebuild
alias dc-db='docker compose down -v --remove-orphans && docker compose up -d --build'   # Complete reset
alias dc-upd='docker compose up -d --force-recreate'                                     # Force recreate containers
alias dc-b='docker compose build --no-cache'                                             # Build without cache
alias dc-bup='docker compose build --no-cache && docker compose up -d'                   # Build without cache and start
alias dc-down-all='docker compose down --rmi all -v --remove-orphans'                    # Remove everything (including images)

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

# ===== Git archive helpers =====

# Create a git archive zip for a project
# Usage: garc <ProjectName> [path...]
# Default: current dir. Override with GARC_OUT env var (e.g. Windows path via WSL)
# Creates the output directory if it does not exist.
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
# Creates the output directory if it does not exist.
gar_one() {
    local project="${1:?Usage: gar_one <ProjectName> [path...]}"
    shift

    local out_dir="/mnt/c/Users/SGL/OneDrive - Contoso/wsl_project"
    local out="${out_dir%/}/${project}.zip"

    # Create the complete parent directory structure
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
# Creates <outdir> if it does not exist.
gout() {
    local out_dir="${1:?Usage: gout <outdir> <ProjectName> [path...]}"
    shift
    GARC_OUT="$out_dir" garc "$@"
}

# ============================================
# LARAVEL – IDE / LARAVEL IDEA
# ============================================
alias ideu='rm -rf vendor/_laravel_idea && composer dump-autoload'

# ============================================
# LARAVEL – IDE / LARAVEL IDEA
# ============================================
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
# === BASIC DOCKER COMPOSE ===
# dc-ub                    # Build and start all services
# dc-db                    # Complete reset (clean and rebuild)
# dc-l app                 # Follow logs for 'app' service
# dc-e db bash             # Get shell inside 'db' container
# d-top                    # Monitor resource usage
# d-prune                  # Aggressive cleanup (removes everything)
# dc-down-all              # Remove compose project completely
#
# === HELPER FUNCTIONS ===
#
# docker-clean-safe
#   Safe cleanup: removes stopped containers, unused images & networks.
#   Volumes are preserved.
#   Example:  docker-clean-safe
#
# docker-summary
#   Print overview of containers, images, volumes and networks.
#   Example:  docker-summary
#
# docker-shell <container> [shell]
#   Open an interactive shell inside a running container.
#   Default shell: /bin/bash
#   Examples:
#     docker-shell app
#     docker-shell app /bin/sh
#     docker-shell db bash
#
# dc-service-up <service>
#   Rebuild and start a single Compose service.
#   Example:  dc-service-up nginx
#             dc-service-up app
#
# dc-service-re <service>
#   Restart a single Compose service.
#   Example:  dc-service-re db
#             dc-service-re redis
#
# dc-service-logs <service> [lines]
#   Follow logs for a specific service (default last 50 lines).
#   Examples:
#     dc-service-logs app
#     dc-service-logs db 100
#     dc-service-logs nginx 200
#
# dc-service-shell <service> [shell]
#   Open a shell inside a Compose service container.
#   Default shell: /bin/bash
#   Examples:
#     dc-service-shell app
#     dc-service-shell app sh
#     dc-service-shell db bash
#
# docker-logs-with-time <container> [lines]
#   Follow container logs with timestamps (default last 50 lines).
#   Examples:
#     docker-logs-with-time app
#     docker-logs-with-time nginx 100
#     docker-logs-with-time db 200
#
# garc <ProjectName> [path...]
#   Create a git archive zip of the current HEAD.
#   Default output: ./<ProjectName>.zip
#   Override folder with GARC_OUT env var.
#   Creates the output directory if it does not exist.
#   Examples:
#     garc MyApp
#     garc AliasOnly alias
#     GARC_OUT=/mnt/c/Users/YourName/Desktop garc MyApp
#     GARC_OUT=/mnt/d/Backups garc MyApp
#
# gout <outdir> <ProjectName> [path...]
#   Set output dir and run garc (creates outdir if missing).
#   Examples:
#     gout ../2026/09 091200AttendancePUSHCommunication
#     gout ~/jenge MyApp
#     gout /mnt/d/Backups MyApp
#
# gar_one <ProjectName> [path...]
#   Create a git archive zip to OneDrive wsl_project folder.
#   Output: /mnt/c/Users/SGL/OneDrive - Contoso/wsl_project/<ProjectName>.zip
#   Creates the folder if it does not exist.
#   Examples:
#     gar_one MyApp
#     gar_one AttendancePUSHCommunication
#     gar_one AliasOnly alias
#
# greset1
#   Soft reset last commit (keeps changes staged)
#   Example:  greset1
#
# greset
#   Delete HEAD ref (use with caution)
#   Example:  greset
#
# ============================================
# END OF ALIASES
# ============================================

EOF
