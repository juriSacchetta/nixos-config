# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal NixOS configuration repository using flakes and Home Manager. The configuration is modular, with system-level settings in `configuration.nix` and user-level settings managed via Home Manager in `home.nix`.

## Essential Commands

### Building and Applying Configuration

```bash
# Apply system configuration changes (requires sudo)
sudo nixos-rebuild switch --flake ~/nixos-config

# Apply system configuration without switching (test boot)
sudo nixos-rebuild boot --flake ~/nixos-config

# Test configuration without making it default
sudo nixos-rebuild test --flake ~/nixos-config

# Update flake inputs (nixpkgs, home-manager, etc.)
nix flake update
```

### Development Environments

```bash
# Enter dev-tools shell (provides lspci, glxinfo, vulkaninfo, stress-ng, etc.)
nix develop .#dev-tools
```

### Flake Management

```bash
# Show flake outputs
nix flake show

# Check flake for errors
nix flake check

# Update specific input
nix flake lock --update-input nixpkgs
```

## Architecture

### Flake Structure (flake.nix)

- **Dual nixpkgs**: Uses both stable (25.05) and unstable channels
  - `nixpkgs`: Stable channel (nixos-25.05) for most packages
  - `nixpkgs-unstable`: Unstable channel for specific packages (e.g., netbird)
  - Unstable packages passed via `pkgs-unstable` special argument
- **Inputs**: External dependencies managed by flake
  - `home-manager`: User environment management (release-25.05)
  - `zen-browser`: Zen browser via external flake
  - `oh-my-tmux`: Configuration framework (non-flake)
  - `solaar`: Logitech device manager
  - `nix-flatpak`: Declarative Flatpak management
  - `sops-nix`: Secrets management with age encryption
- **Special Arguments**:
  - `inputs`: All flake inputs passed to modules
  - `pkgs-unstable`: Unstable nixpkgs set (created in flake.nix:35-38)
- **Dev Shells**: Defined in `devShells.x86_64-linux` (flake.nix:66-102)

### Module System

The configuration is split into focused modules in the `modules/` directory:

1. **amd-optimization.nix**: AMD GPU/CPU optimizations
   - Kernel parameters for AMD GPUs (amdgpu driver settings)
   - TLP power management profiles
   - Hardware acceleration setup
   - Current active parameters: gpu_recovery, cwsr_enable=0, VPE disabled via ip_block_mask
   - Optional toggles (commented): runpm, gfx_off, dcdebugmask for specific issues
   - See inline comments for detailed explanations

2. **desktop.nix**: Desktop environment and input
   - COSMIC desktop environment with cosmic-greeter
   - Keyboard layout configuration (US with altgr-intl variant)
   - Bluetooth support
   - GNOME Keyring integration (critical for git credential storage)
   - XDG portals for desktop integration

3. **flatpak.nix**: Declarative Flatpak package management
   - Flathub remote configuration
   - Managed packages: Logseq, Flatseal, LibreOffice
   - Auto-update on activation
   - Uninstalls unmanaged Flatpaks

### Configuration Files

- **configuration.nix**: System-level configuration
  - Boot settings (systemd-boot, latest kernel)
  - Networking (NetworkManager, Netbird VPN)
  - Services (fingerprint, fstrim, fwupd, Docker)
  - System packages
  - User account definition (user: js)
  - Nix settings (flakes, auto-gc weekly, auto-optimise)

- **home.nix**: User environment via Home Manager
  - User packages (development tools, apps, fonts)
  - Program configurations:
    - Git with libsecret credential helper
    - Zsh with powerlevel10k, zoxide, fzf
    - Neovim (default editor, with vi/vim aliases)
    - Alacritty terminal (0.98 opacity, MesloLGS Nerd Font)
    - VSCode with Dracula theme and Vim extension
  - Tmux configuration via oh-my-tmux
  - Custom systemd service to fix DBus environment for Wayland
  - Environment variables for Wayland support (NIXOS_OZONE_WL, MOZ_ENABLE_WAYLAND)
  - Aider integration with GitHub Copilot via sops-encrypted token

- **hardware-configuration.nix**: Auto-generated hardware configuration
  - DO NOT manually edit unless necessary
  - Regenerate with: `nixos-generate-config`

- **secrets/**: Encrypted secrets managed by sops-nix
  - `secrets.yaml`: Encrypted secrets file (gitignored, not in repo)
  - `secrets.yaml.example`: Template for creating your own secrets
  - `.keep`: Ensures directory exists in git
  - Uses age encryption with keys stored in `~/.config/sops/age/keys.txt`

### Key Technical Decisions

1. **Kernel**: Latest kernel package (`linuxPackages_latest`) in configuration.nix:26
   - Recent commits show kernel 6.12 downgrade was necessary for GPU stability
   - Now using 6.18+ with specific workarounds

2. **AMD GPU Stability**:
   - CWSR disabled (fixes Gentoo bug #967078)
   - VPE disabled via IP block mask (fixes queue reset failures)
   - GPU recovery enabled
   - IOMMU in passthrough mode
   - Optional parameters commented out: runpm, gfx_off, dcdebugmask
   - Uncomment optional parameters only if experiencing specific issues
   - See modules/amd-optimization.nix for all parameters and detailed comments

3. **Credential Management**:
   - Git uses libsecret (home.nix:139) backed by GNOME Keyring
   - PAM configured to unlock keyring at login (desktop.nix:25-28)
   - Seahorse installed for GUI keyring management
   - GitHub token for Aider stored in sops-encrypted secrets.yaml

4. **Power Management**:
   - TLP used instead of power-profiles-daemon
   - Different profiles for AC vs battery
   - PCIe ASPM forced to performance to prevent GPU issues

5. **Shell Setup**:
   - Zsh with powerlevel10k theme
   - Zoxide for smart directory navigation (`z` command)
   - Custom alias: `update` for system rebuilds
   - Direnv with nix-direnv for per-project environments

6. **Secrets Management**:
   - sops-nix for encrypted secrets
   - Age encryption (keys in ~/.config/sops/age/keys.txt)
   - secrets.yaml is gitignored and NOT in repository
   - Use secrets.yaml.example as template

## Common Patterns

### Adding a System Package

Edit `configuration.nix`, add to `environment.systemPackages`, then rebuild:
```nix
environment.systemPackages = with pkgs; [
  # ... existing packages
  your-package
];
```

### Adding a User Package

Edit `home.nix`, add to `home.packages`, then rebuild:
```nix
home.packages = with pkgs; [
  # ... existing packages
  your-package
];
```

### Using Unstable Package

In `configuration.nix` or `home.nix`, use `pkgs-unstable` instead of `pkgs`:
```nix
# Example from configuration.nix:42
package = pkgs-unstable.netbird;
```

### Adding a New Module

1. Create file in `modules/` directory
2. Add import to `configuration.nix` imports list
3. Module receives `config`, `pkgs`, `inputs`, and special args

### Adding Flatpak Applications

Edit `modules/flatpak.nix`, add to packages list:
```nix
packages = [
  "com.example.App"
];
```

### Managing Secrets with sops-nix

1. Generate age key (one-time):
```bash
age-keygen -o ~/.config/sops/age/keys.txt
```

2. Create secrets file from template:
```bash
cp secrets/secrets.yaml.example secrets/secrets.yaml
```

3. Edit with your values, then encrypt:
```bash
sops -e -i secrets/secrets.yaml
```

4. Reference in configuration:
```nix
sops.secrets.my_secret = { };
# Access via: config.sops.secrets.my_secret.path
```

## Important Notes

- System state version: 25.05 (NEVER change without reading documentation)
- Home Manager state version: 25.05 (must match system)
- Username: js (hardcoded in multiple places)
- Timezone: Europe/Rome
- Locale: en_US.UTF-8 with Italian regional settings
- Home Manager backups created with .backup extension
- Nix garbage collection runs weekly, removes >7 day old generations
- **Secrets**: The actual `secrets/secrets.yaml` file is gitignored and NOT in the repository
  - Use `secrets/secrets.yaml.example` as a template to create your own
  - Encrypt with sops before use
  - Never commit unencrypted secrets
