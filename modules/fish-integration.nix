# Imported into every wrapper by wrappers/default.nix
{ config, lib, ... }:

{
  options.fishIntegration = lib.mkOption {
    type = lib.types.submodule ../lib/fish-integration-type.nix;
    default = { };
    description = "How this program hooks into fish; consumed by the `shell` package";
  };
  config.passthru.fishIntegration = config.fishIntegration;
}
