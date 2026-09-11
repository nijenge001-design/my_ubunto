# Bash Aliases Collection

A practical Bash toolkit for speeding up common **Docker, Docker Compose, Laravel, Livewire, Git, Node/NPM, and development workflows**.

The collection provides short aliases for repetitive commands and helper functions for common maintenance tasks.

---

## ✨ What This Includes

| Area | What you get |
|---|---|
| 🐳 **Docker** | Container, image, network, volume, cleanup, shell, log, and resource shortcuts |
| 🐙 **Docker Compose** | Start, stop, rebuild, reset, logs, service management, and container access |
| 🎯 **Laravel** | Artisan shortcuts, generators, migrations, queues, and development helpers |
| ⚡ **Livewire** | Component, page, form, and layout generators |
| 🔧 **Git** | Common Git operations and project archive helpers |
| 📦 **Node/NPM** | Frontend development shortcuts |
| 🛠️ **Helper Functions** | Safe cleanup, service operations, container shells, logs, and archives |

These are the main categories already covered by the original collection. 

---

# 🚀 Installation

## 1. Copy the aliases file

From the directory containing this file:

```bash
cp .bash_aliases ~/.bash_aliases
```

## 2. Load it from `~/.bashrc`

Add the following to `~/.bashrc` if it is not already present:

```bash
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
```

## 3. Reload Bash

```bash
source ~/.bashrc
```

The original installation flow uses these same three steps: copy the file, source it from `~/.bashrc`, then reload the shell. 

---

# ⚡ Quick Reference

## General / Shell

| Alias | Command | Purpose |
|---|---|---|
| `sb` | `source ~/.bashrc` | Reload Bash configuration |
| `cls` | `clear` | Clear the terminal |
| `ll` | `ls -lah` | List files with details |
| `..` | `cd ..` | Go up one directory |
| `...` | `cd ../..` | Go up two directories |
| `myip` | `hostname -I` | Show local IP addresses |
| `ports` | `netstat -tulnp` | Show listening ports |


---

# 🔧 Git

| Alias | Command | Purpose |
|---|---|---|
| `gs` | `git status` | Show working-tree status |
| `ga` | `git add .` | Stage all changes |
| `gc` | `git commit -m` | Create a commit with a message |
| `gp` | `git push` | Push commits to the remote |
| `gl` | `git pull` | Pull changes from the remote |
| `greset1` | `git reset --soft HEAD~1` | Undo the last commit and keep changes staged |
| `greset` | `git update-ref -d HEAD` | Delete the current `HEAD` reference ⚠️ |

> **⚠️ Caution:** `greset` is destructive and should only be used when you understand its effect. 

---

# 🐳 Docker

## Basic Docker Commands

| Alias | Purpose |
|---|---|
| `d-ps` | List running containers |
| `d-psa` | List all containers |
| `d-images` | List all images |
| `d-logs` | Follow container logs |
| `d-logs-n` | Follow the last 100 log lines |
| `d-top` | Show live resource usage |
| `d-port` | Show container port mappings |


## Docker Cleanup

| Alias | Purpose | Risk |
|---|---|---|
| `d-prune` | Remove all unused Docker data | ⚠️ High |
| `d-prune-containers` | Remove stopped containers | Medium |
| `d-prune-images` | Remove unused images | Medium |
| `d-prune-volumes` | Remove unused volumes | ⚠️ High |
| `d-prune-networks` | Remove unused networks | Low |

The original collection marks `d-prune` as a destructive cleanup command. 

---

# 🐙 Docker Compose

## Common Commands

| Alias | Command | Purpose |
|---|---|---|
| `dc-u` | `docker compose up -d` | Start services in the background |
| `dc-ub` | `docker compose up -d --build` | Build and start services |
| `dc-d` | `docker compose down` | Stop and remove containers |
| `dc-dv` | `docker compose down -v` | Stop containers and remove volumes |
| `dc-do` | `docker compose down -v --remove-orphans` | Full Compose cleanup |
| `dc-l` | `docker compose logs -f` | Follow service logs |
| `dc-ps` | `docker compose ps` | Show service status |
| `dc-e` | `docker compose exec` | Execute a command inside a service |


## Advanced Commands

| Alias | Purpose |
|---|---|
| `dc-dbu` | Clean rebuild |
| `dc-db` | Complete environment reset |
| `dc-upd` | Force container recreation |
| `dc-b` | Build without cache |
| `dc-bup` | Build without cache and start |
| `dc-down-all` | Remove everything, including images ⚠️ |


---

# 🎯 Laravel

## Core Shortcuts

| Alias | Command | Purpose |
|---|---|---|
| `a` | `php artisan` | Short form of Artisan |
| `crd` | `composer run dev` | Start the Composer development script |
| `ln` | `laravel new` | Create a new Laravel project |


## Make / Generate Commands

| Alias | Creates |
|---|---|
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


## Database Migrations

| Alias | Command | Purpose |
|---|---|---|
| `mg` | `migrate` | Run pending migrations |
| `mgf` | `migrate:fresh` | Drop all tables and recreate them |
| `mgr` | `migrate:refresh` | Roll back and re-run migrations |
| `mgb` | `migrate:rollback` | Roll back the latest migration batch |
| `mgs` | `migrate:status` | Show migration status |


## Queue Management

| Alias | Command | Purpose |
|---|---|---|
| `qw` | `queue:work` | Start a queue worker |
| `ql` | `queue:listen` | Listen for queued jobs |
| `qf` | `queue:failed` | List failed jobs |
| `qrt` | `queue:retry` | Retry a failed job |
| `qr` | `queue:restart` | Restart queue workers |


---

# ⚡ Livewire

| Alias | Creates |
|---|---|
| `mlw` | Livewire component |
| `mlwp` | Livewire page component |
| `lwf` | Livewire form |
| `lwl` | Livewire layout |


---

# 🛠️ Helper Functions

## Docker Helpers

```bash
# Safely clean unused Docker resources while preserving volumes
docker-clean-safe

# Display a Docker resource overview
docker-summary

# Open a shell inside a container
docker-shell <container> [shell]

# Follow container logs with timestamps
docker-logs-with-time <container> [lines]
```


## Docker Compose Service Helpers

```bash
# Rebuild and start a service
dc-service-up <service>

# Restart a service
dc-service-re <service>

# Follow logs for a service
dc-service-logs <service> [lines]

# Open a shell inside a service
dc-service-shell <service> [shell]
```


## Git Archive Helpers

```bash
# Create an archive in the current directory
garc <ProjectName> [path...]

# Create an archive in the configured OneDrive folder
gar_one <ProjectName> [path...]

# Create an archive in a specific output directory
gout <outdir> <ProjectName> [path...]
```


## Laravel IDE Helpers

```bash
# Quickly regenerate IDE helper files
ideu

# Run the full IDE helper update with status output
ide-update
```


---

# 📚 Usage Examples

## Docker Compose Workflow

```bash
# Build and start all services
dc-ub

# Follow application logs
dc-l app

# Open a shell in the database container
dc-e db bash

# Completely reset and rebuild the environment
dc-db
```


## Laravel Development

```bash
# Create a controller
mctl UserController

# Run migrations
mg

# Start a queue worker
qw

# List routes
rl
```


## Project Archives

```bash
# Archive the current project
garc MyApp

# Archive to OneDrive
gar_one MyApp

# Archive to a specific directory
gout ~/backups MyApp
```


---

# ⚙️ Customization

## Configure OneDrive

The `gar_one` helper uses a hard-coded OneDrive location. Update it to match your environment:

```bash
local out_dir="/mnt/c/Users/YOUR_USERNAME/OneDrive - YOUR_ORG/wsl_project"
```


## Add Your Own Aliases

Add custom aliases to the end of the file:

```bash
# ============================================
# CUSTOM ALIASES
# ============================================

alias myalias='my command'
```


---

# ⚠️ Safety Notes

Some commands can permanently remove data or change repository state. Use them carefully.

| Command | Action | Risk |
|---|---|---|
| `d-prune` | Removes all unused Docker data, including volumes | 🔴 High |
| `dc-down-all` | Removes containers, images, volumes, and orphaned resources | 🔴 High |
| `greset` | Deletes the current `HEAD` reference | 🔴 High |
| `dbw` | Drops all database tables | 🔴 High |

These destructive commands are explicitly identified in the original README. 

> **Best practice:** Read the command definition before running any destructive alias in a production or important development environment.

---

# ✅ Requirements

Make sure the following are installed:

- **Bash 4.0+**
- **Docker**
- **Docker Compose**
- **PHP**
- **Composer**
- **Git**
- **Node.js**
- **npm**

These are the dependencies documented by the original project. 

---

# 📄 License

**MIT License** — Free to use, modify, and distribute according to the terms of the license. 

---

## 💡 Tip

Keep aliases short and memorable, but avoid aliases that hide destructive commands. For team environments, prefer aliases that are easy for another developer to understand without needing to inspect the Bash file.
