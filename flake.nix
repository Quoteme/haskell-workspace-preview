{
  description = "A system-dashboard wirtten in Haskell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:numtide/flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        myGHC = pkgs.haskellPackages.ghcWithPackages (hpkgs: with hpkgs; [
          gtk
        ]);
      in
        rec {
          defaultPackage = packages.package_name;
          packages.package_name = pkgs.stdenv.mkDerivation {
            name = "haskell-workspace-preview";
            pname = "haskell-workspace-preview";
            version = "1.0";
            src = ./src;
          
            nativeBuildInputs = with pkgs; [
              myGHC
            ];
            buildInputs = with pkgs; [];
            buildPhase = ''
              mkdir -p $out/bin
              mkdir -p $out/tmp
              cp -r $src/* $out/tmp
              ghc -o $out/bin/haskell-workspace-preview $out/tmp/Main.hs
              chmod +x $out/bin/haskell-workspace-preview
              rm -rf $out/tmp
            '';
            dontInstall = true;
          };
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              myGHC
            ];
          };
        }
      );
}
