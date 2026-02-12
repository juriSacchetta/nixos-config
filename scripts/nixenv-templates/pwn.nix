# Description: Binary exploitation and pwn challenges
{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Debuggers
    gdb

    # Python and pwntools
    python3
    python3Packages.pip
    python3Packages.pwntools
    python3Packages.virtualenv

    # Binary analysis tools
    binutils
    file
    ltrace
    strace
    checksec

    # SMT solver
    z3

    # Optional: Uncomment as needed
    # radare2
    # ghidra
    # patchelf
    # ropper

    # Python package manager
    uv
  ];

  shellHook = ''
    # Add tenrec to PATH
    export PATH="/home/js/.local/share/tenrec-venv/bin:$PATH"
    echo "================================================"
    echo "  PWN Environment - Binary Exploitation"
    echo "================================================"
    echo ""
    echo "Tools available:"
    echo "  • gdb - GNU Debugger"
    echo "  • python3 + pwntools - Exploit development"
    echo "  • checksec - Binary security checker"
    echo "  • ltrace/strace - System call tracing"
    echo ""
    echo "To install GEF (GDB Enhanced Features):"
    echo "  wget -q -O ~/.gdbinit-gef.py https://gef.blah.cat/py"
    echo "  echo 'source ~/.gdbinit-gef.py' >> ~/.gdbinit"
    echo ""
    echo "Tip: Create a Python venv for challenge-specific deps:"
    echo "  python -m venv .venv && source .venv/bin/activate"
    echo "================================================"

    # Set up a temporary working directory marker
    export PS1="(pwn) $PS1"
  '';
}
