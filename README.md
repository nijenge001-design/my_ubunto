# Bash Aliases Collection

A comprehensive collection of shell aliases and helper functions for **Docker**, **Docker Compose**, **Laravel**, **Git**, and general development workflows.

## Features

- 🐳 **Docker** – Container, image, network, and volume management
- 🐙 **Docker Compose** – Service orchestration shortcuts
- 🎯 **Laravel** – Artisan commands, migrations, queues, and generators
- ⚡ **Livewire** – Component generation shortcuts
- 🔧 **Git** – Common git operations and archive helpers
- 📦 **Node/NPM** – Frontend build shortcuts
- 🛠️ **Helper Functions** – Safe cleanup, container shells, service-specific operations

## Installation

1. **Copy the aliases file** to your home directory:
   ```bash
   cp .bash_aliases ~/.bash_aliases
   ```

2. **Ensure `~/.bashrc` sources it** (add if not present):
   ```bash
   # In ~/.bashrc
   if [ -f ~/.bash_aliases ]; then
       . ~/.bash_aliases
   fi
   ```

3. **Reload your shell**:
   ```bash
   source ~/.bashrc
   ```

## Quick Reference

### General / Shell

| Alias | Command | Description |
|-------|---------|-------------|
| `sb` | `source ~/.bashrc` | Reload bash configuration |
| `cls` | `clear` | Clear terminal |
| `ll` | `ls -lah` | List all files with details |
| `..` | `cd ..` | Go up one directory |
| `...` | `cd ../..` | Go up two directories |
| `myip` | `hostname -I` | Show local IP |
| `ports` | `netstat -tulnp` | Show listening ports |

### Git

| Alias | Command | Description |
|-------|---------|-------------|
| `gs` | `git status` | Show status |
| `ga` | `git add .` | Stage all changes |
| `gc` | `git commit -m` | Commit with message |
| `gp` | `git push` | Push to remote |
| `gl` | `git pull` | Pull from remote |
| `greset1` | `git reset --soft HEAD~1` | Undo last commit (keep staged) |
| `greset` | `git update-ref -d HEAD` | Delete HEAD ref ⚠️ |

### Docker – Basic

| Alias | Description |
|-------|-------------|
| `d-ps` | List running containers |
| `d-psa` | List all containers |
| `d-images` | List all images |
| `d-logs` | Follow container logs |
| `d-logs-n` | Follow last 100 lines |
| `d-top` | Live resource stats |
| `d-port` | List port mappings |

### Docker – Cleanup

| Alias | Description |
|-------|-------------|
| `d-prune` | Remove ALL unused data ⚠️ |
| `d-prune-containers` | Remove stopped containers |
| `d-prune-images` | Remove unused images |
| `d-prune-volumes` | Remove unused volumes |
| `d-prune-networks` | Remove unused networks |

### Docker Compose – Basic

| Alias | Command | Description |
|-------|---------|-------------|
| `dc-u` | `docker compose up -d` | Start in background |
| `dc-ub` | `docker compose up -d --build` | Build and start |
| `dc-d` | `docker compose down` | Stop and remove |
| `dc-dv` | `docker compose down -v` | Stop + remove volumes |
| `dc-do` | `docker compose down -v --remove-orphans` | Full cleanup |
| `dc-l` | `docker compose logs -f` | Follow logs |
| `dc-ps` | `docker compose ps` | List with status |
| `dc-e` | `docker compose exec` | Exec into container |

### Docker Compose – Advanced

| Alias | Description |
|-------|-------------|
| `dc-dbu` | Clean rebuild |
| `dc-db` | Complete reset |
| `dc-upd` | Force recreate containers |
| `dc-b` | Build without cache |
| `dc-bup` | Build without cache and start |
| `dc-down-all` | Remove everything including images ⚠️ |

### Laravel – Core

| Alias | Command | Description |
|-------|---------|-------------|
| `a` | `php artisan` | Artisan shorthand |
| `crd` | `composer run dev` | Run composer dev |
| `ln` | `laravel new` | Create new project |

### Laravel – Make Commands

| Alias | Creates |
|-------|---------|
| `mctl` | Controller |
| `mmg` | Migration |
| `mmo` | Model |
| `msd` | Seeder |
| `mf` | Factory |
| `mr` | Form Request |
| `mrs` | API Resource |
| `mmw` | Middleware |
| `mj` | Job |
| `mev` | Event |
| `ml` | Listener |
| `mnt` | Notification |
| `mp` | Policy |
| `mt` | Test |

### Laravel – Migrations

| Alias | Command | Description |
|-------|---------|-------------|
| `mg` | `migrate` | Run migrations |
| `mgf` | `migrate:fresh` | Drop all and re-migrate |
| `mgr` | `migrate:refresh` | Rollback and re-migrate |
| `mgb` | `migrate:rollback` | Rollback last batch |
| `mgs` | `migrate:status` | Show status |

### Laravel – Queue

| Alias | Command | Description |
|-------|---------|-------------|
| `qw` | `queue:work` | Start worker |
| `ql` | `queue:listen` | Listen to queue |
| `qf` | `queue:failed` | List failed jobs |
| `qrt` | `queue:retry` | Retry failed job |
| `qr` | `queue:restart` | Restart workers |

### Livewire

| Alias | Creates |
|-------|---------|
| `mlw` | Livewire component |
| `mlwp` | Livewire page component |
| `lwf` | Livewire form |
| `lwl` | Livewire layout |

## Helper Functions

### Docker

```bash
# Safe cleanup (preserves volumes)
docker-clean-safe

# Print resource overview
docker-summary

# Open shell in container
docker-shell <container> [shell]

# Follow logs with timestamps
docker-logs-with-time <container> [lines]
```

### Docker Compose Services

```bash
# Rebuild and start a service
dc-service-up <service>

# Restart a service
dc-service-re <service>

# Follow service logs
dc-service-logs <service> [lines]

# Shell into a service
dc-service-shell <service> [shell]
```

### Git Archive

```bash
# Create archive in current directory
garc <ProjectName> [path...]

# Create archive to OneDrive folder
gar_one <ProjectName> [path...]

# Set output directory and create archive
gout <outdir> <ProjectName> [path...]
```

### Laravel IDE

```bash
# Quick regenerate IDE helpers
ideu

# Full IDE helper update with status
ide-update
```

## Usage Examples

### Docker Compose Workflow

```bash
# Build and start all services
dc-ub

# Follow logs for app service
dc-l app

# Shell into database container
dc-e db bash

# Complete reset and rebuild
dc-db
```

### Laravel Development

```bash
# Create a new controller
mctl UserController

# Run migrations
mg

# Start queue worker
qw

# List routes
rl
```

### Git Archive

```bash
# Archive current project
garc MyApp

# Archive to OneDrive
gar_one MyApp

# Archive to specific directory
gout ~/backups MyApp
```

## Customization

### OneDrive Path

The `gar_one` function uses a hardcoded OneDrive path. Modify it to match your setup:

```bash
local out_dir="/mnt/c/Users/YOUR_USERNAME/OneDrive - YOUR_ORG/wsl_project"
```

### Adding New Aliases

Add your custom aliases at the end of the file:

```bash
# ============================================
# CUSTOM ALIASES
# ============================================
alias myalias='my command'
```

## Safety Notes

⚠️ **Destructive commands** – Use with caution:

- `d-prune` – Removes ALL unused Docker data including volumes
- `dc-down-all` – Removes containers, images, volumes, and orphans
- `greset` – Deletes HEAD ref
- `dbw` – Drops all database tables

## Requirements

- Bash 4.0+
- Docker & Docker Compose
- PHP & Composer (for Laravel aliases)
- Git
- Node.js & npm (for frontend aliases)

## License

MIT License – Free to use and modify.
