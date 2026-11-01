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
      mode-indicator # PREFIX / COPY / SYNC / NORMAL in status
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
      set -g @normal green

      set -g @nord_tmux_show_status_content 0 # nord: colours only, skip its layout

      setw -g monitor-activity on
      set -g status-left-length 20
      set -g status-right-length 80
      set -g window-status-separator ""

      # mode-indicator: precedence is prefix > any pane mode > synchronized panes > normal
      set -g @mode_indicator_prefix_prompt " PREFIX "
      set -g @mode_indicator_copy_prompt " COPY "
      set -g @mode_indicator_sync_prompt " SYNC "
      set -g @mode_indicator_empty_prompt " NORMAL "
      set -g @mode_indicator_prefix_mode_style "fg=#{@bar_bg},bg=#{@accent},bold"
      set -g @mode_indicator_copy_mode_style "fg=#{@bar_bg},bg=#{@alert},bold"
      set -g @mode_indicator_sync_mode_style "fg=#{@bar_bg},bg=#{@alert},bold"
      set -g @mode_indicator_empty_mode_style "fg=#{@bar_bg},bg=#{@normal},bold"
      set -g @mode_color "#{?client_prefix,#{@accent},#{?pane_in_mode,#{@alert},#{?pane_synchronized,#{@alert},#{@normal}}}}"
      set -g status-left "#{tmux_mode_indicator}#[fg=#{E:@mode_color},bg=#{@bar_bg}]"

      # unattached sessions (attached ones are visible in their own terminals), then the current session
      set -g status-right "\
      #[fg=#{@muted}]#{S:#{?session_attached,,#{session_name} }}\
      #[fg=#{@session}]#[fg=#{@bar_bg},bg=#{@session},bold] #S "

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
