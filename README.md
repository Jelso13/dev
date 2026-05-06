
# dev

---

A lightweight, decentralized, and modular package manager for dotfiles and system configuration. 

The `dev` script acts as a central controller. It natively manages a core TTY-only environment but can dynamically discover and integrate external graphical environments through a predefined Plugin system.

---

## 🏗️ The Architecture Contract

To keep the central controller clean, both the Core repository and any external Plugins must strictly adhere to the same directory structure. 
```text
dev/ (Core Repository)
├── dev                  # The main CLI entrypoint / controller
├── lib/                 # Shared utilities (logging, stowing, secrets)
├── env/                 # Core GNU Stow packages (bash, tmux, ssh)
├── install_scripts/     # Core dependency installation scripts
├── config_scripts/      # Core configuration logic (git setups, ssh)
└── plugins/             # Git-ignored directory for external collections
    ├── dev-desktop/     # Example Plugin (Cloned automatically)
    │   ├── env/             # GUI Stow packages (picom, awesomewm)
    │   ├── install_scripts/ # GUI Install scripts
    │   └── config_scripts/  # GUI Config scripts
    └── dev-writing/     # Another Example Plugin
        └── ...
```

----------

## 🚀 Usage

The CLI is designed to mimic standard package managers. You can target individual scripts, entire collections, or stack commands.

Bash

```
Usage: dev [OPTIONS] <command> [targets...]

Commands:
  install, i    Run installation scripts for specific targets
  config, c     Run configuration & stow scripts for specific targets
  plugin, p     Manage external configuration modules (add, update, list)

Options:
  -h, --help    Show help message
  -v, --verbose Enable verbose debugging logs
  --dry-run     Simulate actions without modifying the system

```

### Examples

Bash

```
# Stack commands to install and configure multiple tools at once
./dev install nvim awesomewm
./dev config core awesomewm

# Add a predefined plugin collection from the registry
./dev plugin add dev-desktop

# Update all currently installed plugins
./dev plugin update

```

----------

## 📖 User Guide: How to...

### ...add a new Plugin Collection

Plugins are pulled from an internal registry defined in the `dev` script. To add a supported plugin to your system, use the plugin manager:

Bash

```
./dev plugin add dev-writing

```

The controller will automatically look up the Git URL, clone it into `plugins/dev-writing/`, and immediately begin indexing its `install_scripts` and `config_scripts`.

### ...use Secrets in a Configuration Script (Implicit Decryption)

You do not need to manually decrypt your vault before running configurations. The system uses **lazy decryption**.

If your script requires sensitive data (like deploying an SSH key or setting a Git email), simply use the global `get_secret` function. The engine will prompt you for your GPG password exactly _once_ during the run, cache the decrypted payload securely in memory, and pass the required values to any subsequent scripts.

Bash

```
# config_scripts/git
log_info "Configuring Git Identity..."

# The system will prompt for your password here if it hasn't already
local user_email
user_email=$(get_secret "git.email")
local user_name
user_name=$(get_secret "git.name")

git config --global user.name "$user_name"
git config --global user.email "$user_email"

log_pass "Git identity configured."

```

_(Note: To edit your vault manually, simply use standard GPG commands: `gpg --decrypt secret.asc > temp.json`, edit, and re-encrypt)._

### ...create a new Configuration Script

1.  Create a script in `config_scripts/` (or inside a plugin's `config_scripts/`).
    
2.  You do not need to define helper functions! The `dev` controller automatically sources `lib/utils.sh` before running your script.
    
3.  Simply write your logic using the globally available helpers:
    

Bash

```
# config_scripts/mytool
log_info "Configuring mytool..."

# Check dependencies
check_deps mytool || return 1

# Stow the package (Automatically resolves the correct 'env' directory!)
system_stow mytool

log_pass "mytool configured."

```

### ...handle Sub-Components (Complex Targets)

If a configuration requires multiple files, do not write a monolithic script. Promote it to a directory with an `init.sh` entrypoint. The router will natively support it.

Plaintext

```
config_scripts/
└── core/
    ├── init.sh         <-- The router executes this
    ├── 00-base.sh      <-- Sourced by init.sh
    └── 10-ssh.sh       <-- Sourced by init.sh

```

----------

## 🧠 How the Router Works

When you run `./dev config <target>`, the controller does not care where the script lives. It searches the file tree in this strict order:

1.  `$PROJECT_ROOT/config_scripts/<target>` (Core)
    
2.  `$PROJECT_ROOT/plugins/*/config_scripts/<target>` (Plugins)
    

If multiple plugins have a script with the exact same name, the router executes the **first one it finds** and stops. Namespace your plugin scripts carefully if they share common names!

## 🧪 Testing with Docker

Safely test the dotfiles manager in a persistent, read-only Docker sandbox. 

This repository uses a "Holy Trinity" Docker Compose setup:
1. **Total Isolation:** Your live repository is mounted as **Read-Only**. Scripts cannot accidentally delete host files, modify your source code, or mess with local permissions.
2. **Fast Iteration:** Because your host files are mounted, any edits you make to your scripts locally are instantly available inside the container.
3. **Persistent Downloads:** Heavy installations (like plugins or language servers) are written to a container-only anonymous volume. They survive between testing sessions but will never sync back to clutter your host machine.

### 1. Spin Up Environments
Start all pre-configured testing containers in the background. Do this once.
```bash
cd .docker && docker compose up -d
```

### 2. Run Heavy Installs & Test
Jump into an interactive shell to test. You will be logged in as a standard, non-root user (`tester`). 
*(Note: Run your heavy install scripts like `./dev install core` once; the downloads will persist as long as the container exists).*

*   **Debian (Standard Desktop Emulation):**
    ```bash
    docker compose exec -it debian bash
    ```
*   **Arch Linux (Standard Desktop Emulation):**
    ```bash
    docker compose exec -it arch bash
    ```
*   **Debian (No Sudo):** Tests error handling when root is unavailable.
    ```bash
    docker compose exec -it debian-nosudo bash
    ```

### 3. Clean Slate Reset
If an environment gets completely corrupted and you want to wipe it (including all persistent plugin downloads), use the `-v` flag to destroy the anonymous volumes, then restart it:
```bash
# Stop, remove the container, AND delete its persistent volumes
docker compose rm -f -s -v debian

# Spin up a completely fresh environment
docker compose up -d debian
```

> **Note:** If GPG throws terminal errors during testing, run `export GPG_TTY=$(tty)` inside the container before executing your scripts.
```
