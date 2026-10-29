{
  config,
  lib,
  ...
}:

{
  nix-direnv.enable = true;
  extraConfig.global.hide_env_diff = true;
  fishIntegration.interactiveInit = "${lib.getExe config.wrapper} hook fish | source";
}
