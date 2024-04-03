
{
  description = "Python Project";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pythonEnv = pkgs.python312.withPackages
        (pythonPkgs: [ pythonPkgs.pandas ]);
    in {
      devShells.${system}.default =
        pkgs.mkShell { packages = [ pythonEnv ]; };
    };
}
