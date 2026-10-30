{
  wrappers,
  pkgs, # instantiated with system
  lib,
  alnPkgs, # final package set; only passed to wrappers whose file asks for it
  inputs, # flake inputs; likewise
}:

let
  outerArgs = { inherit alnPkgs inputs; };
in
lib.pipe ./. [
  builtins.readDir
  (lib.filterAttrs (n: t: n != "default.nix" && (t == "directory" || lib.hasSuffix ".nix" n)))
  (lib.mapAttrs' (
    n: _:
    let
      wrapperName = lib.removeSuffix ".nix" n;
      # upstream wrapper module if it exists, else our own in ../modules
      # (which, like upstream modules, imports its own base, e.g. wlib.modules.default)
      baseWrapper =
        wrappers.wrappers.${wrapperName}
          or (wrappers.lib.evalModule ../modules/${wrapperName}.nix).config;
      # a wrapper file is a module, or `{ alnPkgs?, inputs? }: <module>` if it needs
      # other packages here or flake inputs; it gets only the args it names
      myWrapper =
        let
          f = import ./${n};
          args = if lib.isFunction f then lib.functionArgs f else { };
        in
        if lib.any (a: args ? ${a}) (lib.attrNames outerArgs) then
          f (builtins.intersectAttrs args outerArgs)
        else
          f;
    in
    {
      name = wrapperName;
      # apply config then instantiate with pkgs (with system)
      value =
        (baseWrapper.apply {
          imports = [
            ../modules/fish-integration.nix
            myWrapper
          ];
        }).wrap
          { inherit pkgs; };
    }
  ))
]
