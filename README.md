# NixOS Configuration

Personal NixOS configuration using flakes and Home Manager for my daily driver system. This configuration is modular, declarative, and optimized for AMD hardware with COSMIC desktop environment.

## System Specifications

- **Desktop Environment**: COSMIC with cosmic-greeter
- **Hardware**: AMD CPU/GPU (Strix Point optimizations)
- **Kernel**: Latest Linux kernel with AMD-specific optimizations
- **Shell**: Zsh with powerlevel10k theme
- **Editor**: Neovim (default) + VSCode
- **Terminal**: Alacritty with Wayland support

## Features

### Modular Architecture

The configuration is split into focused modules for maintainability:

- **amd-optimization.nix**: GPU/CPU optimizations, TLP power management, hardware acceleration
- **desktop.nix**: COSMIC desktop, keyboard layouts, Bluetooth, GNOME Keyring integration
- **flatpak.nix**: Declarative Flatpak management with auto-updates

### Dual Channel Setup

Uses both stable (25.05) and unstable nixpkgs channels:

- Most packages from stable for reliability
- Select packages (e.g., netbird) from unstable for latest features

### Development Tools

Includes a development shell with hardware diagnostics tools:

```bash
nix develop .#dev-tools
```

Provides: lspci, glxinfo, vulkaninfo, stress-ng, and more.

## Quick Start

### Prerequisites

- NixOS installed with flakes enabled
- Git configured with authentication

### Clone and Apply

```bash
# Clone the repository
git clone https://github.com/yourusername/nixos-config.git ~/nixos-config
cd ~/nixos-config

# Review and modify configuration files
# Update hardware-configuration.nix for your hardware:
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix

# Apply the configuration
sudo nixos-rebuild switch --flake ~/nixos-config
```

## Configuration Structure

```
nixos-config/
├── flake.nix                    # Flake configuration and inputs
├── flake.lock                   # Locked dependency versions
├── configuration.nix            # System-level configuration
├── home.nix                     # User environment (Home Manager)
├── hardware-configuration.nix   # Hardware-specific settings
├── modules/
│   ├── amd-optimization.nix     # AMD GPU/CPU optimizations
│   ├── desktop.nix              # Desktop environment setup
│   └── flatpak.nix              # Flatpak package management
└── CLAUDE.md                    # AI assistant instructions
```

## Common Tasks

### Updating the System

```bash
# Update flake inputs
nix flake update

# Apply system changes
sudo nixos-rebuild switch --flake ~/nixos-config

# Or use the custom alias (if shell already configured)
update
```

### Adding Packages

**System packages** (configuration.nix):

```nix
environment.systemPackages = with pkgs; [
  your-package
];
```

**User packages** (home.nix):

```nix
home.packages = with pkgs; [
  your-package
];
```

**Unstable packages**:

```nix
# Use pkgs-unstable instead of pkgs
package = pkgs-unstable.your-package;
```

**Flatpak applications** (modules/flatpak.nix):

```nix
packages = [
  "com.example.App"
];
```

### Testing Changes

```bash
# Test without making default
sudo nixos-rebuild test --flake ~/nixos-config

# Build for next boot only
sudo nixos-rebuild boot --flake ~/nixos-config
```

## Key Technical Details

### AMD GPU Stability

Critical kernel parameters for GPU stability:

- MES (Micro Engine Scheduler) disabled: `amdgpu.mes=0`
- Runtime PM disabled: `amdgpu.runpm=0`
- GPU recovery enabled
- IOMMU in passthrough mode

See `modules/amd-optimization.nix` for complete configuration.

### Credential Management

Git credentials managed via:

- libsecret credential helper
- GNOME Keyring (unlocked via PAM at login)
- Seahorse for GUI keyring management

### Power Management

- TLP instead of power-profiles-daemon
- Separate profiles for AC and battery power
- PCIe ASPM forced to performance mode

## Development Shells

### dev-tools

Hardware diagnostics and stress testing:

```bash
nix develop .#dev-tools
```

Includes: lspci, glxinfo, vulkaninfo, nvtop, stress-ng, s-tui, mesa-demos

## Flake Inputs

- **nixpkgs**: NixOS 25.05 stable channel
- **nixpkgs-unstable**: Latest packages
- **home-manager**: User environment management
- **zen-browser**: Privacy-focused browser
- **oh-my-tmux**: Tmux configuration framework
- **solaar**: Logitech device manager
- **nix-flatpak**: Declarative Flatpak management

## Notes

This is a **personal configuration** tailored to my specific hardware and workflow. While you're welcome to fork and adapt it for your own use, please note:

- This repo is not accepting pull requests
- Hardware-specific optimizations may not apply to your system
- Always review and test configurations before applying
- The `hardware-configuration.nix` is specific to my machine

## State Versions

- **NixOS**: 25.05
- **Home Manager**: 25.05

**Important**: Do not change state versions without reading the NixOS manual section on state version migration.

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Flakes Documentation](https://nixos.wiki/wiki/Flakes)
- [COSMIC Desktop](https://system76.com/cosmic)
