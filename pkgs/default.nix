{
  pkgs,
  lib,
}:

lib.pipe ./. [
  builtins.readDir
  (lib.filterAttrs (n: t: t == "directory" || (n != "default.nix" && lib.hasSuffix ".nix" n)))
  (lib.mapAttrs' (
    n: t:
    if t == "directory" then
      {
        name = n;
        value = import ./${n} { inherit pkgs; };
      }
    else 
      {
        name = lib.removeSuffix ".nix" n;
        value = pkgs.callPackage ./${n} { };
      }
  ))
]
