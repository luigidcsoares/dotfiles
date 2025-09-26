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
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-wsl,
      home-manager,
      catppuccin,
      ...
    }:
    let
      system = "x86_64-linux";
      username = "luigidcsoares";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nixos-wsl.nixosModules.wsl
          (import ./system {
            inherit username;
            configRevision = self.rev or null;
          })
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."${username}" = (
              import ./home {
                inherit catppuccin username;
                rootPath = self.outPath;
              }
            );
          }
        ];
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pkgs.git
          pkgs.lua-language-server
        ];
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

            - Ru `echo "use flake" > .envrc`  
            - Run `direnv allow`
          '';
        };

        "python/jupyterlab" = {
          path = ./templates/python/jupyterlab;
          description = "Python template using Poetry2Nix (Jupyter Lab)";
          welcomeText = ''
            # Getting started

            - Run `git init`
            - Run `git add flake.nix pyproject.toml poetry.lock`
            - Run `nix develop` to enter the development shell

            # Adding/updating python packages

            - Update pyproject.toml to add, remove, or update dependencies
            - Run `poetry lock` (with `--no-update`, if you don't want to upgrade dependencies)
            - Run `nix develop` to enter the development shell

            # Optional

            You may want to automate the last step with direnv:  

            - Run `printf 'watch_file poetry.lock\nuse flake' > .envrc`  
            - Run `direnv allow`
          '';
        };
      };
    };
}
