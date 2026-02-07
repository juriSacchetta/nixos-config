# Description: Reverse engineering and binary analysis
{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Debuggers and disassemblers
    gdb
    radare2

    # Analysis tools
    binutils
    file
    strings
    hexyl

    # Optional heavy tools (uncomment as needed)
    # ghidra
    # ida-free
    # angr (via python)

    # Utilities
    python3
    python3Packages.pip
    ltrace
    strace
  ];

  shellHook = ''
    echo "================================================"
    echo "  REV Environment - Reverse Engineering"
    echo "================================================"
    echo ""
    echo "Tools available:"
    echo "  • gdb - GNU Debugger"
    echo "  • radare2 - Reverse engineering framework"
    echo "  • binutils - objdump, nm, strings, etc."
    echo "  • hexyl - Hex viewer"
    echo ""
    echo "Tip: Uncomment ghidra/ida-free in the env definition"
    echo "      if you need GUI tools (large downloads)"
    echo "================================================"

    export PS1="(rev) $PS1"
  '';
}
