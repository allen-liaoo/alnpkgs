{
  config,
  lib,
  wlib,
  pkgs,
  ...
}:

{
  imports = [ wlib.modules.default ];

  options.settings = lib.mkOption {
    type = with lib.types; attrsOf anything; # attrset values become `[delta "<name>"]` subsections
    default = { };
    description = ''
      Options for delta's `[delta]` section (git-config syntax).
      See <https://dandavison.github.io/delta/configuration.html>
    '';
  };

  config = {
    package = lib.mkDefault pkgs.delta;
    constructFiles.generatedConfig = {
      relPath = "${config.binName}-config";
      content = lib.generators.toGitINI { delta = config.settings; };
    };
    # read this instead of ~/.gitconfig
    flags."--config" = config.constructFiles.generatedConfig.path;
  };
}
