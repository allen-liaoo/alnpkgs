{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.theme = lib.mkOption {
    type = with lib.types; either package str;
    default = pkgs.tmuxPlugins.nord;
    description = ''
      A tmux theme plugin (sourced as a plugin), or a path to a tmux conf file with
      colors (sourced last). Paths may be out of store (pass a string, not a nix path).
    '';
  };

  config = {
    sourceSensible = true;
    prefix = "C-Space";
    terminal = "tmux-256color";
    terminalOverrides = ",*:RGB"; # outer terminal supports truecolor
    escapeTime = 0;
    historyLimit = 50000;
    modeKeys = "vi";
    statusKeys = "vi";
    vimVisualKeys = true; # copy mode: v = begin selection, y = yank
    mouse = true;
    aggressiveResize = true;

    # plugin scripts (sensible, yank, themes) call `tmux`; without it on PATH they silently do nothing.
    # Prepended so a different tmux version on PATH can't be picked up instead.
    prefixVar = [
      [
        "PATH"
        ":"
        "${config.package}/bin"
      ]
    ];

    plugins = [
      pkgs.tmuxPlugins.yank # yank to system clipboard
    ]
    ++ lib.optional (lib.isDerivation config.theme) config.theme;

    configBefore = ''
      set -g renumber-windows on
      set -g set-clipboard on

      # splits and new windows keep the current directory
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # vim-like pane navigation and resizing
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # sensible's R reloads ~/.tmux.conf; reload the packaged config instead
      bind R source-file ${config.constructFiles.generatedConfig.path} \; display "Reloaded tmux config"
    '';

    configAfter = lib.optionalString (!lib.isDerivation config.theme) ''
      source-file -q "${config.theme}"
    '';
  };
}
