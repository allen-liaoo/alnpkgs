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
    prefix = "C-a";
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

    plugins = with pkgs.tmuxPlugins; [
      yank # yank to system clipboard
      resurrect
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

      # status line: layout lives here, colours are named so a theme only sets these (terminal palette names)
      set -g @bar_bg black
      set -g @bar_fg white
      set -g @muted brightblack
      set -g @accent cyan
      set -g @session blue
      set -g @alert yellow
      set -g @nord_tmux_show_status_content 0 # nord: colours only, skip its layout

      setw -g monitor-activity on
      set -g status-right-length 80
      set -g window-status-separator ""

      set -g status-left "#[fg=#{@bar_bg},bg=#{@session},bold] #S #[fg=#{@session},bg=#{@bar_bg},nobold]"

      # unattached sessions (attached ones are visible in their own terminals), then mode indicators
      set -g status-right "\
      #[fg=#{@muted}]#{S:#{?session_attached,,#{session_name} }}\
      #{?pane_synchronized,#[fg=#{@bar_bg}#,bg=#{@alert}#,bold] SYNC ,}\
      #{?#{==:#{pane_mode},copy-mode},#[fg=#{@bar_bg}#,bg=#{@alert}#,bold] COPY ,}\
      #{?client_prefix,#[fg=#{@bar_bg}#,bg=#{@accent}#,bold] PREFIX ,}"

      # windows with activity or a bell get alert-coloured text
      set -g window-status-format "\
      #[fg=#{@bar_bg},bg=#{@muted}]\
      #[fg=#{?#{||:#{window_activity_flag},#{window_bell_flag}},#{@alert},#{@bar_fg}}] #I #W #F \
      #[fg=#{@muted},bg=#{@bar_bg}]"
      set -g window-status-current-format "\
      #[fg=#{@bar_bg},bg=#{@accent}]\
      #[fg=#{@bar_bg}] #I #W #F \
      #[fg=#{@accent},bg=#{@bar_bg}]"

      # sensible's R reloads ~/.tmux.conf; reload the packaged config instead
      bind R source-file ${config.constructFiles.generatedConfig.path} \; display "Reloaded tmux config"
    '';

    configAfter = lib.optionalString (!lib.isDerivation config.theme) ''
      source-file -q "${config.theme}"
    '';
  };
}
