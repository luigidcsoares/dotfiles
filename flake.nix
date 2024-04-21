# flake.nix
{
  description = "NixOS WSL Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neorg-overlay.url = "github:nvim-neorg/nixpkgs-neorg-overlay";
  };

  outputs =
    { self, nixpkgs, nixos-wsl, home-manager, neorg-overlay, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nixos-wsl.nixosModules.wsl
          ./system
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [ neorg-overlay.overlays.default ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.luigidcsoares = import ./home;
          }
        ];
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ pkgs.git pkgs.lua-language-server ];
      };

      templates = {
        latex = {
          path = ./templates/latex;
          description = "Minimal LaTeX template";
          welcomeText = ''
            # Getting started
            - Add your latex packages into `texEnv` in `flake.nix`
            - Run `nix develop` to enter the environment

            # Optional

            You may want to automate the last step with direnv:  

            - Run `echo "use flake" > .envrc`  
            - Run `direnv allow`
          '';
        };

        "python/jupyterlab" = {
          path = ./templates/python/jupyterlab;
          description = "Python template using Poetry2Nix (Jupyter Lab)";
          welcomeText = ''
            # Getting started

            - Update the Python version in both flake.nix and pyproject.toml
            - Add the Python packages you need to pyproject.toml
            - Run `git init`
            - Run `git add flake.nix pyproject.toml poetry.lock`
            - Run `nix develop`

            # Optional

            You may want to automate the last step with direnv:  

            - Run `echo "use flake" > .envrc`  
            - Run `direnv allow`
          '';
        };

        "python/molten" = {
          path = ./templates/python/molten;
          description = "Python template using Poetry2Nix (Neovim with Molten)";
          welcomeText = ''
            # Getting started

            - Update the Python version in both flake.nix and pyproject.toml
            - Add the Python packages you need to pyproject.toml
            - Run `git init`
            - Run `git add flake.nix pyproject.toml poetry.lock`
            - Run `nix develop`

            # Optional

            You may want to automate the last step with direnv:  

            - Run `echo "use flake" > .envrc`  
            - Run `direnv allow`
          '';
        };
      };
    };
}