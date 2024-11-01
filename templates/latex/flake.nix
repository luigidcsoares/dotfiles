{
  description = "LaTeX project";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      texEnv = pkgs.texliveBasic.withPackages (texPkgs: [
        texPkgs.latexmk
        ### Fonts
        texPkgs.avantgar
        texPkgs.bookman
        texPkgs.charter
        texPkgs.cmextra
        texPkgs.cm-super
        texPkgs.courier
        texPkgs.euro
        texPkgs.euro-ce
        texPkgs.eurosym
        texPkgs.fpl
        texPkgs.helvetic
        texPkgs.manfnt-font
        texPkgs.marvosym
        texPkgs.mathpazo
        texPkgs.mflogo-font
        texPkgs.ncntrsbk
        texPkgs.palatino
        texPkgs.pxfonts
        texPkgs.rsfs
        texPkgs.symbol
        texPkgs.times
        texPkgs.txfonts
        texPkgs.utopia
        texPkgs.wasy
        texPkgs.wasy-type1
        texPkgs.wasysym
        texPkgs.zapfchan
        texPkgs.zapfding
      ]);
    in {
      devShells.${system}.default =
        pkgs.mkShell { packages = [ texEnv ]; };
    };
}

