{
  description = "LaTeX project";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      texEnv =
        pkgs.texliveBasic.withPackages (texPkgs: [ texPkgs.latexmk ]);
    in {
      devShells.${system}.default =
        pkgs.mkShell { packages = [ texEnv ]; };
    };
}

