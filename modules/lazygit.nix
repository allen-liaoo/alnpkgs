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
    type = wlib.types.structuredValueWith { typeName = "YAML"; };
    default = { };
    description = ''
      Content of lazygit's config.yml.
      See <https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md>
    '';
  };

  config = {
    package = lib.mkDefault pkgs.lazygit;
    constructFiles.generatedConfig = {
      relPath = "${config.binName}-config.yml";
      content = builtins.toJSON config.settings; # JSON is valid YAML
    };
    env.LG_CONFIG_FILE = config.constructFiles.generatedConfig.path;
  };
}
