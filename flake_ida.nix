{
  description = "IDA Pro development environment with Tenrec MCP framework";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # IDA Pro installation directory - UPDATE THIS PATH IF NEEDED
        idaProDir = "/home/js/ida-pro-9.1";

        # All required libraries for IDA Pro
        libraries = with pkgs; [
          # Graphics libraries (for libGLX.so.0 and Qt platform plugins)
          libGL
          libGLU
          mesa

          # X11 libraries
          xorg.libX11
          xorg.libXext
          xorg.libXi
          xorg.libxcb
          xorg.libXrender
          xorg.libXrandr
          xorg.libXfixes
          xorg.libXdamage
          xorg.libXcomposite
          xorg.libXcursor
          xorg.libXinerama
          xorg.libXtst
          xorg.libSM
          xorg.libICE

          # XCB utilities (CRITICAL for Qt platform plugins)
          xorg.xcbutil
          xorg.xcbutilimage
          xorg.xcbutilkeysyms
          xorg.xcbutilrenderutil
          xorg.xcbutilwm
          xorg.xcbutilcursor

          # Qt dependencies
          libxkbcommon
          fontconfig
          freetype
          dbus
          glib

          # Wayland support
          wayland
          libdrm

          # System libraries
          zlib
          stdenv.cc.cc.lib
          openssl
          alsa-lib
          libpulseaudio

          # Python for IDAPython and Tenrec
          python311
          python311Packages.pip
        ];

        # Tenrec Python package - install from PyPI
        tenrecPython = pkgs.python311Packages.buildPythonPackage rec {
          pname = "tenrec";
          version = "0.2.3"; # Update to latest version
          format = "wheel";

          src = pkgs.python311Packages.fetchPypi {
            inherit pname version format;
            dist = "py3";
            python = "py3";
            sha256 = ""; # Will be auto-filled by Nix or use `nix-prefetch-url`
          };

          propagatedBuildInputs = with pkgs.python311Packages; [
            # Core dependencies
            pydantic
            click
            fastapi
            uvicorn

            # Add other dependencies as needed
            # Check PyPI or the project's pyproject.toml for complete list
          ];

          # Skip tests as they may require IDA Pro
          doCheck = false;

          meta = with pkgs.lib; {
            description =
              "A headless, extendable, multi-session MCP framework for IDA Pro";
            homepage = "https://github.com/axelmierczuk/tenrec";
            license = licenses.mit;
          };
        };

        # Alternative: Install tenrec using pip in a virtual environment
        tenrecEnv =
          pkgs.python311.withPackages (ps: with ps; [ pip virtualenv ]);

        # Library path for all wrappers
        libPath = pkgs.lib.makeLibraryPath libraries;

        # Common environment variables
        commonEnv = ''
          export LD_LIBRARY_PATH="${libPath}:$LD_LIBRARY_PATH"
          export QT_QPA_PLATFORM_PLUGIN_PATH="${idaProDir}/plugins/platforms"
          export QT_QPA_PLATFORM=xcb
          export QT_DEBUG_PLUGINS=0
          export PYTHON3="${pkgs.python311}/bin/python3"
          export IDADIR="${idaProDir}"
        '';

        # Create wrapper script for IDA GUI
        idaWrapper = pkgs.writeShellScriptBin "ida" ''
          ${commonEnv}

          # Auto-configure IDAPython on first run
          if [ ! -f "${idaProDir}/.idapython_configured" ]; then
            echo "Configuring IDAPython for the first time..."
            "${idaProDir}/idapyswitch" --force-path "${pkgs.python311}/bin/python3" 2>/dev/null || true
            touch "${idaProDir}/.idapython_configured"
          fi

          exec "${idaProDir}/ida64" "$@"
        '';

        ida64Wrapper = pkgs.writeShellScriptBin "ida64" ''
          ${commonEnv}
          exec "${idaProDir}/ida64" "$@"
        '';

        idatWrapper = pkgs.writeShellScriptBin "idat" ''
          ${commonEnv}
          exec "${idaProDir}/idat64" "$@"
        '';

        idapyswitchWrapper = pkgs.writeShellScriptBin "idapyswitch" ''
          ${commonEnv}
          exec "${idaProDir}/idapyswitch" "$@"
        '';

        # Tenrec wrapper with proper environment
        tenrecWrapper = pkgs.writeShellScriptBin "tenrec" ''
          ${commonEnv}

          # Add Python packages to path
          export PYTHONPATH="${tenrecEnv}/${pkgs.python311.sitePackages}:$PYTHONPATH"

          # Check if tenrec is installed in venv, otherwise suggest installation
          if [ ! -d "$HOME/.local/share/tenrec-venv" ]; then
            echo "Tenrec virtual environment not found."
            echo "Creating virtual environment and installing tenrec..."
            python3 -m venv "$HOME/.local/share/tenrec-venv"
            source "$HOME/.local/share/tenrec-venv/bin/activate"
            pip install tenrec
            echo "Tenrec installed successfully!"
          fi

          source "$HOME/.local/share/tenrec-venv/bin/activate"
          exec tenrec "$@"
        '';

      in {
        # Development shell (recommended usage)
        devShells.default = pkgs.mkShell {
          buildInputs = libraries ++ [
            idaWrapper
            ida64Wrapper
            idatWrapper
            idapyswitchWrapper
            tenrecWrapper
            tenrecEnv
          ];

          shellHook = ''
            ${commonEnv}
            export PYTHONPATH="${pkgs.python311}/lib/python3.11/site-packages:$PYTHONPATH"

            # Setup tenrec virtual environment if it doesn't exist
            if [ ! -d "$HOME/.local/share/tenrec-venv" ]; then
              echo "Setting up Tenrec for first time use..."
              python3 -m venv "$HOME/.local/share/tenrec-venv"
              source "$HOME/.local/share/tenrec-venv/bin/activate"
              pip install --quiet tenrec
              deactivate
            fi

            echo "╔════════════════════════════════════════════╗"
            echo "║  IDA Pro + Tenrec Environment Activated   ║"
            echo "╚════════════════════════════════════════════╝"
            echo ""
            echo "IDA Pro Commands:"
            echo "  ida         - Launch IDA Pro GUI (auto-configures Python)"
            echo "  ida64       - Launch IDA Pro GUI"
            echo "  idat        - Launch IDA Pro in terminal mode"
            echo "  idapyswitch - Manually configure IDAPython"
            echo ""
            echo "Tenrec MCP Framework:"
            echo "  tenrec run       - Start Tenrec MCP server"
            echo "  tenrec install   - Install MCP client configuration"
            echo "  tenrec plugins   - Manage plugins"
            echo "  tenrec docs      - Generate plugin documentation"
            echo ""
            echo "Environment:"
            echo "  Python: $(python3 --version)"
            echo "  IDA Location: ${idaProDir}"
            echo "  IDADIR: $IDADIR"
            echo ""
            echo "Quick Start:"
            echo "  1. Run 'tenrec install' to configure your MCP client"
            echo "  2. Run 'tenrec run' to start the server"
            echo "  3. Use your MCP client (Claude Code, etc.) to interact"
            echo ""
          '';
        };

        # Tenrec-specific development shell
        devShells.tenrec = pkgs.mkShell {
          buildInputs = libraries ++ [ tenrecWrapper tenrecEnv idatWrapper ];

          shellHook = ''
            ${commonEnv}

            # Activate tenrec venv if it exists
            if [ -d "$HOME/.local/share/tenrec-venv" ]; then
              source "$HOME/.local/share/tenrec-venv/bin/activate"
            fi

            echo "Tenrec Development Environment"
            echo "=============================="
            echo "IDADIR: $IDADIR"
            echo ""
            echo "Run 'tenrec --help' for available commands"
          '';
        };

        # Alternative: FHS environment for maximum compatibility
        packages.default = pkgs.buildFHSUserEnv {
          name = "ida-pro";

          targetPkgs = pkgs: libraries;

          runScript = pkgs.writeShellScript "ida-run" ''
            export QT_QPA_PLATFORM_PLUGIN_PATH="${idaProDir}/plugins/platforms"
            export PYTHON3="${pkgs.python311}/bin/python3"
            export IDADIR="${idaProDir}"

            # Auto-configure IDAPython
            if [ ! -f "${idaProDir}/.idapython_configured" ]; then
              echo "Configuring IDAPython..."
              "${idaProDir}/idapyswitch" --force-path "${pkgs.python311}/bin/python3" 2>/dev/null || true
              touch "${idaProDir}/.idapython_configured"
            fi

            exec "${idaProDir}/ida64" "$@"
          '';

          meta = {
            description =
              "IDA Pro reverse engineering tool with Tenrec support";
            platforms = pkgs.lib.platforms.linux;
          };
        };

        # Package for terminal version with Tenrec
        packages.idat = pkgs.buildFHSUserEnv {
          name = "idat";

          targetPkgs = pkgs: libraries;

          runScript = pkgs.writeShellScript "idat-run" ''
            export PYTHON3="${pkgs.python311}/bin/python3"
            export IDADIR="${idaProDir}"
            exec "${idaProDir}/idat64" "$@"
          '';
        };

        # Standalone Tenrec package
        packages.tenrec = tenrecWrapper;
      });
}
