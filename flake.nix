{
  outputs =
    {
      self,
      nixpkgs,
      wrappers,
    }:
    let
      forAllSystems = with nixpkgs.lib; genAttrs platforms.all;
      pkgsPerSystem = (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          lib = pkgs.lib;
          # fixpoint: packages can reference each other through alnPkgs
          alnPkgs =
            (import ./wrappers { inherit wrappers pkgs lib alnPkgs; })
            // (import ./pkgs { inherit pkgs lib; });
        in
        alnPkgs
      );
    in
    {
      packages = forAllSystems pkgsPerSystem;
      legacyPackages = forAllSystems pkgsPerSystem;
      apps = forAllSystems (
        system:
        (
          with nixpkgs.lib;
          pipe system [
            pkgsPerSystem
            (filterAttrs (_: p: p ? meta && p.meta ? mainProgram))
            (mapAttrs (
              n: p: {
                type = "app";
                program = "${p}/bin/${p.meta.mainProgram}";
              }
            ))
          ]
        )
      );
    };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    wrappers = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
