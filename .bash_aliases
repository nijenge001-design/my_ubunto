#!/bin/bash
# Docker and Docker Compose Aliases
# Created: 2024
# Last updated: 2024
# source ~/.bashrc

# ============================================
# DOCKER COMPOSE ALIASES
# ============================================

# General commands
alias sb='source ~/.bashrc'
alias ln='laravel new'

# Basic Docker Compose commands
alias dc-u='docker compose up -d'                    # Start containers in background
alias dc-ub='docker compose up -d --build'           # Build and start containers
alias dc-d='docker compose down'                      # Stop and remove containers
alias dc-dv='docker compose down -v'                  # Stop and remove containers + volumes
alias dc-do='docker compose down -v --remove-orphans' # Complete cleanup (containers, volumes, orphans)
alias dc-re='docker compose restart'                   # Restart all containers
alias dc-l='docker compose logs -f'                    # Follow logs from all containers
alias dc-l100='docker compose logs -f --tail=100'      # Follow last 100 lines of logs
alias dc-e='docker compose exec'                       # Execute command in running container
alias dc-ps='docker compose ps'                         # List containers with status
alias dc-stop='docker compose stop'                     # Stop containers without removing
alias dc-start='docker compose start'                   # Start stopped containers
alias dc-pull='docker compose pull'                     # Pull latest images
alias dc-config='docker compose config'                 # Validate and view compose file

# ============================================
# COMBINED DOCKER COMPOSE COMMANDS
# ============================================

alias dc-dbu='docker compose down -v && docker compose up -d --build'                    # Clean rebuild
alias dc-db='docker compose down -v --remove-orphans && docker compose up -d --build'   # Complete reset
alias dc-upd='docker compose up -d --force-recreate'                                     # Force recreate containers
alias dc-b='docker compose build --no-cache'                                             # Build without cache
alias dc-bup='docker compose build --no-cache && docker compose up -d'                   # Build without cache and start
alias dc-down-all='docker compose down --rmi all -v --remove-orphans'                    # Remove everything (including images)

# ============================================
# DOCKER SYSTEM COMMANDS
# ============================================

alias d-ps='docker ps'                                   # List running containers
alias d-psa='docker ps -a'                               # List all containers
alias d-images='docker images'                           # List all images
alias d-prune='docker system prune -af --volumes'        # Remove all unused data (CAUTION!)
alias d-prune-containers='docker container prune -f'     # Remove stopped containers
alias d-prune-images='docker image prune -af'            # Remove unused images
alias d-prune-volumes='docker volume prune -f'           # Remove unused volumes
alias d-prune-networks='docker network prune -f'         # Remove unused networks

# ============================================
# DOCKER MONITORING & DEBUGGING
# ============================================

alias d-top='docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"'
alias d-inspect='docker inspect'                          # Show detailed container info
alias d-logs='docker logs -f'                             # Follow container logs
alias d-logs-n='docker logs -f --tail=100'                # Follow last 100 lines of container logs
alias d-history='docker history'                          # Show image history
alias d-port='docker port'                                # List port mappings

# ============================================
# DOCKER NETWORK COMMANDS
# ============================================

alias dn-ls='docker network ls'                         # List networks
alias dn-inspect='docker network inspect'               # Inspect network
alias dn-create='docker network create'                 # Create network
alias dn-prune='docker network prune -f'                # Remove unused networks

# ============================================
# OTHER COMMANDS
# ============================================
alias cls='clear'   

# ============================================
# DOCKER VOLUME COMMANDS
# ============================================

alias dv-ls='docker volume ls'                          # List volumes
alias dv-inspect='docker volume inspect'                # Inspect volume
alias dv-prune='docker volume prune -f'                 # Remove unused volumes
alias dv-create='docker volume create'                  # Create volume

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


# ============================================
# DOCKER COMPOSE HELPER FUNCTIONS
# ============================================

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



# ============================================
# Laravel 
# ============================================

# ===== Core =====
alias a='php artisan'
alias crd='composer run dev'
alias pad='php artisan dev'

# ===== Routes =====
alias rc='a route:cache'
alias rcl='a route:clear'
alias rl='a route:list'

# ===== Storage =====
alias sl='a storage:link'
alias sul='a storage:unlink'

# ===== Stubs =====
alias sp='a stub:publish'

# ===== Sail =====
alias sa='a sail:add'
alias si='a sail:install'
alias spub='a sail:publish'

# ===== Queue =====
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
# ===============================
# MAKE (m*)
# ===============================
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
#alias mmo='a make:model'
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

# ===============================
# MIGRATIONS (mg*)
# ===============================
alias mg='a migrate'
alias mgf='a migrate:fresh'
alias mgi='a migrate:install'
alias mgr='a migrate:refresh'
alias mgreset='a migrate:reset'
alias mgb='a migrate:rollback'
alias mgs='a migrate:status'

# ===============================
# DATABASE (db*)
# ===============================
alias dbm='a db:monitor'
alias dbs='a db:seed'
alias dbsh='a db:show'
alias dbt='a db:table'
alias dbw='a db:wipe'
               
# ===============================
# Livewire (lw*)
# ===============================
alias lwa='a livewire:attribute'
alias lwc='a livewire:config'
alias lwcv='a livewire:convert'
alias lwf='a livewire:form'
alias lwl='a livewire:layout'
alias lws='a livewire:stubs'

# ===============================
# Make Livewire
# ===============================
alias mlw='a make:livewire'
alias mlwp='a make:livewire pages::'

alias pstress='./vendor/bin/pest stress '
# ===== General =====
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'


# ===== Git =====
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'

# ===== Node / Frontend =====
alias dev='npm run dev'
alias build='npm run build'

# ===== Networking =====
alias myip='hostname -I'
alias ports='netstat -tulnp'


# ============================================
# USAGE EXAMPLES (COMMENTED)
# ============================================

# === BASIC USAGE ===
# dc-ub                    # Build and start all services
# dc-db                    # Complete reset (clean and rebuild)
# dc-l app                 # Follow logs for 'app' service
# dc-e db bash             # Get shell inside 'db' container
# d-top                    # Monitor resource usage
#
# === SERVICE-SPECIFIC ===
# dc-service-up nginx      # Rebuild and start only nginx
# dc-service-logs db 100   # Show last 100 lines of db logs
# dc-service-shell app sh  # Get sh shell in app container
#
# === CLEANUP ===
# docker-clean-safe        # Safe cleanup (preserves volumes)
# d-prune                  # Aggressive cleanup (removes everything)
# dc-down-all              # Remove compose project completely
#
# === INFORMATION ===
# docker-summary           # Show overview of Docker resources
# dc-ps                    # List compose project containers
# d-inspect container      # Show detailed container info

# ============================================
# END OF ALIASES
# ============================================
