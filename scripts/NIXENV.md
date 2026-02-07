# nixenv - Ephemeral Nix Shell Environment Manager

A simple command-line tool for managing isolated, ephemeral Nix development environments. Perfect for CTF challenges, quick experiments, or any task requiring temporary, clean environments.

## Quick Start

```bash
# List available environments
nixenv
# or
nixenv list

# Enter an environment (creates a fresh, isolated shell)
nixenv enter pwn

# Create a new environment
nixenv new forensics

# Edit an existing environment
nixenv edit pwn

# Show environment definition
nixenv show pwn
```

## Features

- **Ephemeral**: Each activation creates a fresh environment, exit and it's gone
- **Isolated**: Environments don't interfere with each other or your system
- **Portable**: Environment definitions are stored in your NixOS config and versioned with git
- **Flexible**: Easy to customize or create new environments on the fly
- **Manual activation**: Only active when you explicitly enter them, no directory-based auto-activation

## Pre-installed Environments

### pwn - Binary Exploitation
Tools: gdb, pwntools, checksec, ltrace, strace, binutils

```bash
nixenv enter pwn
```

### web - Web Exploitation
Tools: burpsuite, sqlmap, python3 (requests, beautifulsoup4), nodejs, curl, nmap

```bash
nixenv enter web
```

### rev - Reverse Engineering
Tools: gdb, radare2, binutils, hexyl, ltrace, strace

```bash
nixenv enter rev
```

### crypto - Cryptography
Tools: python3 (pycryptodome, gmpy2, sympy), sage, openssl

```bash
nixenv enter crypto
```

## Creating Custom Environments

### Method 1: Interactive (Recommended)

```bash
nixenv new myenv
```

This creates a template and opens it in your editor. Example:

```nix
# Description: My custom environment
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Add packages here
    python3
    nodejs
    jq
  ];

  shellHook = ''
    echo "Welcome to myenv!"
    # Custom initialization
  '';
}
```

### Method 2: Manual

Create a file at `~/.config/nixenv/envs/myenv.nix` with the structure above.

## Advanced Usage

### Adding Packages On-the-Fly

You can add extra packages when entering an environment:

```bash
nixenv enter pwn -p ltrace -p angr
```

### Environment-Specific Python Packages

For challenge-specific Python dependencies, create a venv inside the environment:

```bash
nixenv enter pwn
# Now inside the pwn environment:
python -m venv .venv
source .venv/bin/activate
pip install your-challenge-specific-package
```

The venv is local to your challenge directory and won't pollute other environments.

### Editing Environments

```bash
nixenv edit pwn
```

Opens the environment definition in your $EDITOR (defaults to nvim).

After editing, just run `nixenv enter pwn` again - no rebuild needed! Nix will automatically use the updated definition.

## Use Cases

### CTF Competitions
Each challenge gets a fresh environment with exactly the tools you need:

```bash
cd challenge1
nixenv enter pwn
# ... work on challenge ...
exit

cd ../challenge2
nixenv enter web
# Fresh environment, different tools
```

### Quick Experiments
Test something without polluting your system:

```bash
nixenv enter crypto
# Play with cryptography tools
exit
# All gone, system clean
```

### Development Environments
Create project-specific environments:

```bash
nixenv new myproject
nixenv edit myproject
# Add project dependencies
nixenv enter myproject
```

## Environment Definitions Location

All environments are stored in: `~/.config/nixenv/envs/`

These are automatically synced when you run `nixos-rebuild switch` via your home.nix configuration.

## Tips

1. **Keep environments focused**: Create specific environments for specific tasks rather than one giant environment
2. **Use descriptive names**: `forensics`, `android-rev`, `web-php`, etc.
3. **Document your environments**: Add good descriptions and comments
4. **Version control**: Your environment definitions are in your NixOS config git repo
5. **Share environments**: Copy your .nix files to share with teammates

## Architecture

- **Script**: `~/nixos-config/scripts/nixenv`
- **Templates**: `~/nixos-config/scripts/nixenv-templates/`
- **User environments**: `~/.config/nixenv/envs/`
- **Integration**: Defined in `home.nix` as a shell script package

## Troubleshooting

**Environment not found?**
```bash
nixenv list  # Check what's available
```

**Want to update pre-installed environments?**
Edit the templates in `~/nixos-config/scripts/nixenv-templates/`, then rebuild:
```bash
update  # Your alias for nixos-rebuild switch
```

**Need help?**
```bash
nixenv help
```
