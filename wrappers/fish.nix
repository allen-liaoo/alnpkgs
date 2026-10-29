{ config, ... }:

# Plain fish config: no knowledge of other programs (see pkgs/shell for that)
{
  # also read ~/.config/fish (universal variables, history, fish_config saves);
  # the packaged config is sourced after it
  flags."--no-config" = false;

  # resolves to this wrapper, so a re-wrapped fish (e.g. `shell`) points at itself; tmux inherits it
  env.SHELL = config.wrapperPaths.placeholder;

  abbreviations = {
    c = "cd";
  };

  configFile.content = ''
    # disable fish greeting
    set fish_greeting
    # disable command not found
    function fish_command_not_found; end

    fish_default_key_bindings
    fish_vi_key_bindings
    set fish_cursor_default block
    set fish_cursor_insert block blink

    # n dots = go up (n-1) dirs: ... = cd ../../
    function multicd
      echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
    end
    abbr --add dotdot --regex '^\.\.+$' --function multicd

    # choose theme based on environment variable
    function apply-my-theme --on-variable=fish_theme
      fish_config theme choose $fish_theme
    end
  '';
}
