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
   - CRITICAL: MES is disabled (`amdgpu.mes=0`) for stability
   - Runtime PM disabled (`amdgpu.runpm=0`) to prevent GPU suspend issues

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

- **hardware-configuration.nix**: Auto-generated hardware configuration
  - DO NOT manually edit unless necessary
  - Regenerate with: `nixos-generate-config`

### Key Technical Decisions

1. **Kernel**: Latest kernel package (`linuxPackages_latest`) in configuration.nix:26
   - Recent commits show kernel 6.12 downgrade was necessary for GPU stability

2. **AMD GPU Stability**:
   - MES (Micro Engine Scheduler) disabled for stability
   - GPU recovery enabled
   - IOMMU in passthrough mode
   - See modules/amd-optimization.nix for all parameters

3. **Credential Management**:
   - Git uses libsecret (home.nix:139) backed by GNOME Keyring
   - PAM configured to unlock keyring at login (desktop.nix:25-28)
   - Seahorse installed for GUI keyring management

4. **Power Management**:
   - TLP used instead of power-profiles-daemon
   - Different profiles for AC vs battery
   - PCIe ASPM forced to performance to prevent GPU issues

5. **Shell Setup**:
   - Zsh with powerlevel10k theme
   - Zoxide for smart directory navigation (`z` command)
   - Custom alias: `update` for system rebuilds
   - Direnv with nix-direnv for per-project environments

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

## Important Notes

- System state version: 25.05 (NEVER change without reading documentation)
- Home Manager state version: 25.05 (must match system)
- Username: js (hardcoded in multiple places)
- Timezone: Europe/Rome
- Locale: en_US.UTF-8 with Italian regional settings
- Home Manager backups created with .backup extension
- Nix garbage collection runs weekly, removes >7 day old generations
