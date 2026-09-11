#!/bin/bash
# ============================================
# Docker, Laravel & Dev Aliases
# ============================================
# A comprehensive collection of shell aliases and helper functions
# for Docker, Docker Compose, Laravel, Git, and general development.
#
# Usage:
#   Copy this file to ~/.bash_aliases
#   Then run: source ~/.bashrc
# ============================================

# ============================================
# GENERAL / SHELL
# ============================================
alias sb='source ~/.bashrc'              # Reload bash configuration
alias cls='clear'                        # Clear terminal screen
alias ll='ls -lah'                       # List all files with details
alias la='ls -A'                         # List almost all files
alias l='ls -CF'                         # List files in columns
alias ..='cd ..'                         # Go up one directory
alias ...='cd ../..'                     # Go up two directories
alias myip='hostname -I'                 # Show local IP address(es)
alias ports='netstat -tulnp'             # Show listening ports

# ============================================
# GIT
# ============================================
alias gs='git status'                    # Show working tree status
alias ga='git add .'                     # Stage all changes
alias gc='git commit -m'                 # Commit with message (usage: gc "message")
alias gp='git push'                      # Push to remote
alias gl='git pull'                      # Pull from remote
alias greset1="git reset --soft HEAD~1"  # Undo last commit, keep changes staged
alias greset="git update-ref -d HEAD"    # Delete HEAD ref (CAUTION: destructive)

# ============================================
# NODE / FRONTEND
# ============================================
alias dev='npm run dev'                  # Start development server
alias build='npm run build'              # Build for production

# ============================================
# DOCKER – BASIC
# ============================================
alias d-ps='docker ps'                                   # List running containers
alias d-psa='docker ps -a'                               # List all containers (including stopped)
alias d-images='docker images'                           # List all images
alias d-inspect='docker inspect'                         # Show detailed container/image info (usage: d-inspect <name>)
alias d-logs='docker logs -f'                            # Follow container logs (usage: d-logs <container>)
alias d-logs-n='docker logs -f --tail=100'               # Follow last 100 lines of logs
alias d-history='docker history'                         # Show image layer history (usage: d-history <image>)
alias d-port='docker port'                               # List port mappings (usage: d-port <container>)
alias d-top='docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"'  # Live resource stats

# ============================================
# DOCKER – PRUNE / CLEANUP
# ============================================
alias d-prune='docker system prune -af --volumes'        # Remove ALL unused data (CAUTION: destructive!)
alias d-prune-containers='docker container prune -f'     # Remove stopped containers
alias d-prune-images='docker image prune -af'            # Remove unused images
alias d-prune-volumes='docker volume prune -f'           # Remove unused volumes
alias d-prune-networks='docker network prune -f'         # Remove unused networks

# ============================================
# DOCKER – NETWORKS
# ============================================
alias dn-ls='docker network ls'                          # List networks
alias dn-inspect='docker network inspect'                # Inspect network (usage: dn-inspect <network>)
alias dn-create='docker network create'                  # Create network (usage: dn-create <name>)
alias dn-prune='docker network prune -f'                 # Remove unused networks

# ============================================
# DOCKER – VOLUMES
# ============================================
alias dv-ls='docker volume ls'                           # List volumes
alias dv-inspect='docker volume inspect'                 # Inspect volume (usage: dv-inspect <volume>)
alias dv-prune='docker volume prune -f'                  # Remove unused volumes
alias dv-create='docker volume create'                   # Create volume (usage: dv-create <name>)

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
alias dc-e='docker compose exec'                         # Execute command in running container (usage: dc-e <service> <cmd>)
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
alias dc-down-all='docker compose down --rmi all -v --remove-orphans'                    # Remove everything including images

# ============================================
# LARAVEL – CORE
# ============================================
alias a='php artisan'                    # Shorthand for php artisan
alias crd='composer run dev'             # Run composer dev script
alias pad='php artisan dev'              # Run artisan dev command
alias ln='laravel new'                   # Create new Laravel project (usage: ln <name>)

# ============================================
# LARAVEL – ROUTES
# ============================================
alias rc='a route:cache'                 # Cache routes
alias rcl='a route:clear'                # Clear route cache
alias rl='a route:list'                  # List all routes

# ============================================
# LARAVEL – STORAGE
# ============================================
alias sl='a storage:link'                # Create storage symlink
alias sul='a storage:unlink'             # Remove storage symlink

# ============================================
# LARAVEL – STUBS & SAIL
# ============================================
alias sp='a stub:publish'                # Publish stubs
alias sa='a sail:add'                    # Add Sail service
alias si='a sail:install'                # Install Sail
alias spub='a sail:publish'              # Publish Sail files

# ============================================
# LARAVEL – QUEUE
# ============================================
alias qc='a queue:clear'                 # Clear queued jobs
alias qf='a queue:failed'                # List failed jobs
alias qfl='a queue:flush'                # Flush failed jobs
alias qfg='a queue:forget'               # Delete a failed job (usage: qfg <id>)
alias ql='a queue:listen'                # Listen to queue
alias qm='a queue:monitor'               # Monitor queue size
alias qpb='a queue:prune-batches'        # Prune stale batches
alias qpf='a queue:prune-failed'         # Prune failed jobs
alias qr='a queue:restart'               # Restart queue workers
alias qrt='a queue:retry'                # Retry failed job (usage: qrt <id>)
alias qrb='a queue:retry-batch'          # Retry failed batch (usage: qrb <id>)
alias qw='a queue:work'                  # Start queue worker

# ============================================
# LARAVEL – MAKE (m*)
# ============================================
alias mc='a make:class'                  # Create class (usage: mc <name>)
alias mcmd='a make:command'              # Create artisan command
alias mcmp='a make:component'            # Create Blade component
alias mctl='a make:controller'           # Create controller
alias men='a make:enum'                  # Create enum
alias mev='a make:event'                 # Create event
alias mf='a make:factory'                # Create model factory
alias mi='a make:interface'              # Create interface
alias mj='a make:job'                    # Create job class
alias ml='a make:listener'               # Create event listener
alias mm='a make:mail'                   # Create mailable class
alias mmw='a make:middleware'            # Create middleware
alias mmg='a make:migration'             # Create migration
alias mmo='sleep 2; php artisan make:model'  # Create model (with delay)
alias mnt='a make:notification'          # Create notification
alias mntt='a make:notifications-table'  # Create notifications table migration
alias mob='a make:observer'              # Create model observer
alias mp='a make:policy'                 # Create policy
alias mpr='a make:provider'              # Create service provider
alias mqb='a make:queue-batches-table'   # Create job batches table
alias mqf='a make:queue-failed-table'    # Create failed jobs table
alias mqt='a make:queue-table'           # Create jobs table
alias mr='a make:request'                # Create form request
alias mrs='a make:resource'              # Create API resource
alias mrule='a make:rule'                # Create validation rule
alias msc='a make:scope'                 # Create Eloquent scope
alias msd='a make:seeder'                # Create database seeder
alias mst='a make:session-table'         # Create sessions table
alias mt='a make:test'                   # Create test class
alias mtr='a make:trait'                 # Create trait
alias mv='a make:view'                   # Create Blade view

# ============================================
# LARAVEL – MIGRATIONS (mg*)
# ============================================
alias mg='a migrate'                     # Run migrations
alias mgf='a migrate:fresh'              # Drop all tables and re-migrate
alias mgi='a migrate:install'            # Create migration repository
alias mgr='a migrate:refresh'            # Rollback and re-migrate
alias mgreset='a migrate:reset'          # Rollback all migrations
alias mgb='a migrate:rollback'           # Rollback last batch
alias mgs='a migrate:status'             # Show migration status

# ============================================
# LARAVEL – DATABASE (db*)
# ============================================
alias dbm='a db:monitor'                 # Monitor database connections
alias dbs='a db:seed'                    # Seed database
alias dbsh='a db:show'                   # Show database info
alias dbt='a db:table'                   # Show table info (usage: dbt <table>)
alias dbw='a db:wipe'                    # Drop all tables (CAUTION: destructive)

# ============================================
# LIVEWIRE (lw*)
# ============================================
alias lwa='a livewire:attribute'         # Create Livewire attribute
alias lwc='a livewire:config'            # Publish Livewire config
alias lwcv='a livewire:convert'          # Convert component to Livewire
alias lwf='a livewire:form'              # Create Livewire form
alias lwl='a livewire:layout'            # Create Livewire layout
alias lws='a livewire:stubs'             # Publish Livewire stubs
alias mlw='a make:livewire'              # Create Livewire component
alias mlwp='a make:livewire pages::'     # Create Livewire page component
alias pstress='./vendor/bin/pest stress '  # Run Pest stress test

# ============================================
# HELPER FUNCTIONS
# ============================================

# Safe Docker cleanup (preserves volumes)
# Usage: docker-clean-safe
docker-clean-safe() {
    echo "Cleaning containers, images, and networks..."
    docker container prune -f
    docker image prune -af
    docker network prune -f
    echo "Done! Volumes were preserved."
}

# Print Docker resource overview
# Usage: docker-summary
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

# Open interactive shell in a running container
# Usage: docker-shell <container-name> [shell=/bin/bash]
docker-shell() {
    if [ -z "$1" ]; then
        echo "Usage: docker-shell <container-name> [shell=/bin/bash]"
        return 1
    fi
    local shell="${2:-/bin/bash}"
    docker exec -it "$1" "$shell"
}

# Rebuild and start a single Compose service
# Usage: dc-service-up <service-name>
dc-service-up() {
    if [ -z "$1" ]; then
        echo "Usage: dc-service-up <service-name>"
        return 1
    fi
    docker compose up -d --build "$1"
}

# Restart a single Compose service
# Usage: dc-service-re <service-name>
dc-service-re() {
    if [ -z "$1" ]; then
        echo "Usage: dc-service-re <service-name>"
        return 1
    fi
    docker compose restart "$1"
}

# Follow logs for a specific Compose service
# Usage: dc-service-logs <service-name> [lines=50]
dc-service-logs() {
    if [ -z "$1" ]; then
        echo "Usage: dc-service-logs <service-name> [lines=50]"
        return 1
    fi
    local lines="${2:-50}"
    docker compose logs -f --tail="$lines" "$1"
}

# Exec into a specific Compose service
# Usage: dc-service-shell <service-name> [shell=/bin/bash]
dc-service-shell() {
    if [ -z "$1" ]; then
        echo "Usage: dc-service-shell <service-name> [shell=/bin/bash]"
        return 1
    fi
    local shell="${2:-/bin/bash}"
    docker compose exec "$1" "$shell"
}

# Follow container logs with timestamps
# Usage: docker-logs-with-time <container-name> [lines=50]
docker-logs-with-time() {
    if [ -z "$1" ]; then
        echo "Usage: docker-logs-with-time <container-name> [lines=50]"
        return 1
    fi
    local lines="${2:-50}"
    docker logs -f --tail="$lines" -t "$1"
}

# ============================================
# GIT ARCHIVE HELPERS
# ============================================

# Create a git archive zip for a project
# Usage: garc <ProjectName> [path...]
# Default output: current directory. Override with GARC_OUT env var.
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
    mkdir -p "$out_dir"
    local out="${out_dir%/}/${project}.zip"
    git archive -o "$out" HEAD "$@" || { echo "git archive failed"; return 1; }
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
alias ideu='rm -rf vendor/_laravel_idea && composer dump-autoload'  # Quick regenerate IDE helpers

# Regenerate Laravel Idea helper code
# Usage: ide-update
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
# END OF ALIASES
# ============================================
