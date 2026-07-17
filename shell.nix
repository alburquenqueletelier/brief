{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    bun
    nodejs
  ];

  shellHook = ''
    echo "bun: $(bun --version)"
    if [ ! -d landing/node_modules ]; then
      echo "Run: cd landing && bun install"
    fi
  '';
}
