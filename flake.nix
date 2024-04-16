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
      overlays.default = import overlays/neovim.nix;

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nixos-wsl.nixosModules.wsl
          ./system
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays =
              [ self.overlays.default neorg-overlay.overlays.default ];
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
        python = {
          path = ./templates/python;
          description = "Python template using pure Nix packages";
          welcomeText = ''
            # Getting started
            - Update the Python version in both flake.nix and pyproject.toml
            - Run `nix shell nixpkgs#poetry -c poetry lock`
            - Run `git init`
            - Run `git add flake.nix pyproject.toml poetry.lock`
            - Run `nix develop`

            # Optional

            You may want to automate the process with direnv:  

            - Run `echo "use flake" > .envrc`  
            - Run `direnv allow`
          '';
        };
      };
    };
}