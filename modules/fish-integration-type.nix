# One program's fish integration. Exposed by wrappers as `passthru.fishIntegration`
# and merged by the `shell` package.
{ lib, ... }:

{
  options = with lib.types; {
    enable = lib.mkOption {
      type = bool;
      default = true;
      description = "Whether the shell applies this integration";
    };
    env = lib.mkOption {
      type = attrsOf str;
      default = { };
      description = "Environment variables exported for the whole shell session";
    };
    shellAliases = lib.mkOption {
      type = attrsOf str;
      default = { };
    };
    abbreviations = lib.mkOption {
      # same shapes the fish wrapper module accepts (string or abbreviation spec)
      type = attrsOf (either str (attrsOf anything));
      default = { };
    };
    init = lib.mkOption {
      type = lines;
      default = "";
      description = "Fish code run at startup, e.g. function definitions";
    };
    interactiveInit = lib.mkOption {
      type = lines;
      default = "";
      description = "Fish code run only in interactive shells";
    };
  };
}
