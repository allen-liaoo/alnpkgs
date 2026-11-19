{
  config,
  lib,
  pkgs,
  ...
}:

let
  themeFlavor = "aln-theme";
in
{
  options = {
    theme = lib.mkOption {
      type = with lib.types; either package str;
      default = pkgs.yaziPlugins.nord;
      description = ''
        A yazi flavor: a directory containing `flavor.toml` (and optionally `tmtheme.xml`).
        May be out of store (pass a string, not a nix path); yazi reads it through a symlink on startup.
      '';
    };
    pluginSetup = lib.mkOption {
      type = with lib.types; attrsOf anything;
      default = { };
      example = {
        yatline = { };
        git = {
          order = 1500;
        };
      };
      description = ''
        Plugins whose `setup()` is called from init.lua, mapped to the setup argument
        (`{ }` calls `setup()` without arguments).
      '';
    };
  };

  config = {
    settings.yazi = {
      mgr = {
        show_hidden = false;
        sort_dir_first = true;
        sort_by = "extension";
        show_symlink = true;
      };
    };

    settings.keymap = {
      mgr.prepend_keymap = [
        {
          on = "M";
          run = "plugin mount";
          desc = "View mounts";
        }
        {
          on = "T";
          run = "plugin omni-trash";
          desc = "View trash";
        }
      ];
    };

    plugins = {
      inherit (pkgs.yaziPlugins) mount omni-trash yatline;
    };
    pluginSetup.yatline = { };

    runtimePkgs = with pkgs; [
      trash-cli # required by omni-trash
    ];

    flavors.${themeFlavor} = config.theme;
    settings.theme.flavor = {
      dark = themeFlavor;
      light = themeFlavor;
    };

    constructFiles.initLua = {
      relPath = "${config.binName}-config/init.lua";
      output = config.generatedConfig.output;
      content = lib.concatMapAttrsStringSep "\n" (
        name: arg:
        ''require("${name}"):setup(${lib.optionalString (arg != { }) (lib.generators.toLua { } arg)})''
      ) config.pluginSetup;
    };

    # press q to quit with auto cd; press Q to quit without cd
    fishIntegration.init = ''
      function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        ${lib.getExe config.wrapper} $argv --cwd-file="$tmp"
        if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
          builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
      end
    '';
  };
}
