{
  config,
  pkgs,
  lib,
  ...
}:
with config.theme; {
  options = {
    homeManagerModules.tmux.enable =
      lib.mkEnableOption "enables tmux";
  };
  config = lib.mkIf config.homeManagerModules.tmux.enable {
    programs.tmux = {
      enable = true;
      secureSocket = false; # for some reason, tmux started via hyprland doesnt respect this and I only want 1 tmux server running
      aggressiveResize = true;
      escapeTime = 10; # no delay for escape key, vim style
      prefix = "C-a";
      terminal = "kitty";
      extraConfig =
        /*
        tmux
        */
        ''
          # appearance
          set -g status-left-length 30
          set -g status-left " [#{session_name}] "
          # set -g status-right "#{?window_bigger,[#{window_offset_x}#,#{window_offset_y}] ,}#{=21:pane_title} "
          set -g status-right "#h "
          set -g status-style 'bg=${bg1} fg=${secondary}'
          set -g status-right-style 'bg=${bg1} fg=${primary}'
          # for kitty images in image.nvim
          set -gq allow-passthrough on
          # pane switching
          bind -r h select-pane -L
          bind -r j select-pane -D
          bind -r k select-pane -U
          bind -r l select-pane -R
          # pane resizing
          bind -r ^h resize-pane -L 5
          bind -r ^j resize-pane -D 5
          bind -r ^k resize-pane -U 5
          bind -r ^l resize-pane -R 5
          # new window
          bind -r n new-window
          # window switching
          bind -r [ previous-window
          bind -r ] next-window
          # window splitting
          bind -r v split-window -v
          bind -r b split-window -h
          # close window without confirmation
          bind-key X kill-window
          # close pane without confirmation
          bind-key x kill-pane
          # unset <c-space> to avoid conflicts with vim
          unbind C-Space
          # easy config reload
          bind-key r source-file ~/.config/tmux/tmux.conf \; display-message "tmux.conf reloaded"
          # vim style copy
          unbind p
          bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xsel -i -p && xsel -o -p | xsel -i -b"
          bind-key p run "xsel -o | tmux load-buffer - ; tmux paste-buffer"
        '';
    };
  };
}
