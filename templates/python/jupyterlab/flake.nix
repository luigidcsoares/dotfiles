{
  description = "Python project with Poetry2Nix (Jupyter Lab)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, poetry2nix }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      python = pkgs.python311;
      poetry = poetry2nix.lib.mkPoetry2Nix { inherit pkgs; };
      pythonEnv = poetry.mkPoetryEnv {
        inherit python;
        projectDir = ./.;
        groups = [ "dev" ];
      };
    in {
      devShells.${system}.default =
        pkgs.mkShell { packages = [ pkgs.pyright pythonEnv ]; };

      shellHook = ''
        # Initialize the poetry.lock file if it doesn't exist
        if [ ! -f poetry.lock ]; then
          nix shell nixpkgs#poetry -c poetry lock
        fi

        # Install a kernel with the name of the root directory
        python -m ipykernel install --user --name $(basename $(pwd))
      '';
    };
}
