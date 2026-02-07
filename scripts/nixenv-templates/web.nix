# Description: Web exploitation and hacking challenges
{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Web tools
    burpsuite
    sqlmap

    # Programming languages
    python3
    python3Packages.requests
    python3Packages.beautifulsoup4
    nodejs

    # Network tools
    curl
    wget
    netcat
    nmap

    # Optional: Uncomment as needed
    # ffuf
    # gobuster
    # wfuzz
    # nikto
  ];

  shellHook = ''
    echo "================================================"
    echo "  WEB Environment - Web Exploitation"
    echo "================================================"
    echo ""
    echo "Tools available:"
    echo "  • burpsuite - Web proxy and scanner"
    echo "  • sqlmap - SQL injection tool"
    echo "  • python3 + requests - HTTP client"
    echo "  • nodejs - JavaScript runtime"
    echo "  • curl/wget - HTTP clients"
    echo ""
    echo "Tip: Use 'npm install' for node packages in current dir"
    echo "================================================"

    export PS1="(web) $PS1"
  '';
}
