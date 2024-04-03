
{
  description = "Python Project";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      python = pkgs.python311;
      pythonEnv = python.withPackages (pythonPkgs: [
        pythonPkgs.pandas
        pythonPkgs.jupyter
      ]);
    in {
      devShells.${system}.default =
        pkgs.mkShell { packages = [ pythonEnv ]; };
    };

}
