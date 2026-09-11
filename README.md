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

The examples below show typical development workflows and how the aliases can be combined.

---

## 🐳 Docker Workflow

### Check the Docker environment

```bash
# Show running containers
d-ps

# Show all containers, including stopped containers
d-psa

# Show available images
d-images

# Show container port mappings
d-port

# Show live CPU and memory usage
d-top
```

### Inspect application logs

```bash
# Follow container logs
d-logs my-app

# Follow the last 100 lines and continue streaming
d-logs-n my-app
```

### Open a container shell

```bash
# Open a shell using the helper
docker-shell my-app

# Explicitly use Bash
docker-shell my-app bash

# Explicitly use sh
docker-shell my-app sh
```

---

## 🐙 Docker Compose Workflow

### Start a project

```bash
# Start existing containers in the background
dc-u

# Build images first, then start the services
dc-ub

# Check service status
dc-ps
```

### Work with logs

```bash
# Follow logs for every service
dc-l

# Follow logs for one service
dc-service-logs app

# Follow the last 200 lines of a service
dc-service-logs app 200
```

### Run commands inside services

```bash
# Open a Bash shell in the database service
dc-e db bash

# Open a shell in the application service
dc-service-shell app

# Use sh when Bash is unavailable
dc-service-shell app sh
```

### Rebuild a single service

```bash
# Rebuild and start one service
dc-service-up app

# Restart one service
dc-service-re app
```

### Reset the development environment

```bash
# Stop containers and remove volumes
dc-dv

# Stop containers, remove volumes, and remove orphans
dc-do

# Complete project reset
dc-db
```

> **Warning:** Reset commands can remove database volumes and development data. Use them only when you intentionally want a clean environment.

---

## 🎯 Laravel Workflow

### Start a Laravel project

```bash
# Create a new Laravel application
ln my-project

# Enter the project
cd my-project

# Start the development environment
crd
```

### Use Artisan quickly

Instead of typing:

```bash
php artisan route:list
```

you can use:

```bash
a route:list
```

The `a` alias is simply a shorter way to run Artisan commands.

### Generate a feature

```bash
# Create a controller
mctl EmployeeController

# Create a model
mmo Employee

# Create a migration
mmg create_employees_table

# Create a form request
mr StoreEmployeeRequest

# Create an API resource
mrs EmployeeResource

# Create a policy
mp EmployeePolicy

# Create a job
mj ProcessEmployeeImport
```

### Typical model + migration workflow

```bash
# Create the model
mmo Employee

# Create a migration
mmg create_employees_table

# Run the migration
mg

# Check migration status
mgs
```

### Working with migrations

```bash
# Run pending migrations
mg

# Check migration status
mgs

# Roll back the latest batch
mgb

# Refresh all migrations
mgr

# Drop all tables and rebuild the database
mgf
```

> **Warning:** `mgf` removes the existing database tables before rebuilding them. Do not use it against a production database.

---

## ⚡ Livewire Workflow

### Create a Livewire component

```bash
mlw EmployeeTable
```

### Create a Livewire page

```bash
mlwp Employees/Index
```

### Create a Livewire form

```bash
lwf EmployeeForm
```

### Create a Livewire layout

```bash
lwl AppLayout
```

A common feature workflow might look like:

```bash
# Create the model and migration
mmo Employee
mmg create_employees_table

# Create the Livewire page
mlwp Employees/Index

# Run migrations
mg
```

---

## 📬 Laravel Queue Workflow

### Start a worker

```bash
qw
```

### Monitor failed jobs

```bash
# List failed jobs
qf

# Retry a specific failed job
qrt 5
```

### Restart workers

After deploying new code:

```bash
qr
```

This tells running queue workers to restart gracefully.

---

## 🔧 Git Workflow

### Check your changes

```bash
gs
```

### Stage and commit changes

```bash
ga
gc "Add employee management aliases"
```

### Push changes

```bash
gp
```

### Pull changes

```bash
gl
```

### Undo the latest commit but keep the changes

```bash
greset1
```

> `greset1` uses a soft reset, so your changes remain available.

### Git workflow example

```bash
# 1. Check the current state
gs

# 2. Stage changes
ga

# 3. Commit
gc "Update Bash aliases documentation"

# 4. Push
gp
```

---

## 📦 Project Archive Workflow

### Archive the current project

```bash
garc MyApp
```

### Archive selected paths

```bash
garc MyApp app routes resources
```

### Archive to OneDrive

```bash
gar_one MyApp
```

### Archive to a custom location

```bash
gout ~/backups MyApp
```

### Example backup routine

```bash
# Create a local backup
gout ~/backups MyApp

# Create an additional OneDrive backup
gar_one MyApp
```

---

## 🧰 Helper Function Examples

### Safe Docker cleanup

```bash
docker-clean-safe
```

Use this when you want to clean unused Docker resources while keeping volumes.

### View Docker resources

```bash
docker-summary
```

### Follow timestamped logs

```bash
docker-logs-with-time my-app
```

Or specify the number of lines:

```bash
docker-logs-with-time my-app 200
```

---

## 🔄 Example: Full Laravel + Docker Development Workflow

A typical project session could look like this:

```bash
# Go to the project
cd ~/projects/my-erp

# Start the Docker environment
dc-ub

# Check services
dc-ps

# Open the application container
dc-e app bash

# Inside the container:
mg
mgs

# Leave the container
exit

# Follow application logs
dc-service-logs app

# Check Git changes
gs

# Commit the completed work
ga
gc "Update employee management"
gp
```

---

## 🆘 Troubleshooting Examples

### Check whether services are listening

```bash
ports
```

### Check the machine IP address

```bash
myip
```

### Reload all aliases after editing `.bash_aliases`

```bash
sb
```

### Verify an alias

```bash
type a
type dc-u
type mctl
```

You can also list the command behind an alias:

```bash
alias a
alias dc-u
alias gs
```

---

## 🧭 Quick "Which Command Should I Use?"

| Task | Command |
|---|---|
| Reload Bash | `sb` |
| Check Git status | `gs` |
| Start Docker Compose | `dc-u` |
| Build + start Compose | `dc-ub` |
| View Compose status | `dc-ps` |
| Follow Compose logs | `dc-l` |
| Open a container shell | `docker-shell <container>` |
| Run Artisan | `a <command>` |
| Create controller | `mctl <name>` |
| Create model | `mmo <name>` |
| Create migration | `mmg <name>` |
| Run migrations | `mg` |
| Check migration status | `mgs` |
| Create Livewire component | `mlw <name>` |
| Start queue worker | `qw` |
| List failed jobs | `qf` |
| Retry failed job | `qrt <id>` |
| Create project archive | `garc <ProjectName>` |
| Archive to OneDrive | `gar_one <ProjectName>` |
| Show listening ports | `ports` |

---

## 💡 Recommended Workflow

For day-to-day development, a simple pattern is:

```bash
# Start
dc-ub

# Check
dc-ps

# Develop
mctl EmployeeController
mmo Employee
mg

# Monitor
dc-service-logs app

# Verify
gs

# Commit
ga
gc "Implement employee management"
gp
```

This keeps the common workflow short while still making each command easy to understand.
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
