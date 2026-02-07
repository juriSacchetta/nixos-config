# Description: Cryptography challenges
{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Python and crypto libraries
    python3
    python3Packages.pycryptodome
    python3Packages.gmpy2
    python3Packages.sympy

    # Crypto tools
    openssl

    # Utilities
    sage # Computer algebra system (large package)
  ];

  shellHook = ''
    echo "================================================"
    echo "  CRYPTO Environment - Cryptography"
    echo "================================================"
    echo ""
    echo "Tools available:"
    echo "  • python3 + pycryptodome - Crypto library"
    echo "  • sage - Computer algebra system"
    echo "  • gmpy2 - Multiple precision arithmetic"
    echo "  • openssl - Crypto toolkit"
    echo ""
    echo "================================================"

    export PS1="(crypto) $PS1"
  '';
}
