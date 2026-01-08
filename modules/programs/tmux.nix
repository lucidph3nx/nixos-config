{
  config,
  lib,
  ...
}:
with config.theme;
let
  background = if type == "dark" then bg0 else bg_dim;
in
{
  options = {
    nx.programs.tmux.enable = lib.mkEnableOption "enables tmux" // {
      default = true;
    };
  };
  config = lib.mkIf config.nx.programs.tmux.enable {
    home-manager.users.ben = {
      programs.tmux = {
        enable = true;
        secureSocket = false; # for some reason, tmux started via hyprland doesnt respect this and I only want 1 tmux server running
        aggressiveResize = true;
        escapeTime = 10; # no delay for escape key, vim style
        prefix = "C-a";
        terminal = "kitty";
        extraConfig =
          # tmux
          ''
            # appearance
            set -g status-left-length 30
            set -g status-left " [#{session_name}] "
            # set -g status-right "#{?window_bigger,[#{window_offset_x}#,#{window_offset_y}] ,}#{=21:pane_title} "
            set -g status-right "#h "
            set -g status-style 'bg=${bg1} fg=${secondary}'
            set -g status-left-style 'bg=${bg1} fg=${secondary}'
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
            bind -r c new-window
            # window switching
            bind -r p previous-window
            bind -r n next-window
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
            # floating popup terminal (similar to toggleterm)
            bind -n C-Space if-shell -F '#{m:popup-*,#{session_name}}' {
              detach-client
            } {
              run-shell 'POPUP_SESSION="popup-$(tmux display-message -p \"#S\")" && tmux display-popup -E -w 80% -h 80% -b single -S "fg=${primary},bg=${background}" "tmux new-session -A -s \"$POPUP_SESSION\" \\; set status off"'
            }
            # vim style copy
            set -g mode-keys vi
            bind-key -T copy-mode-vi 'v' send -X begin-selection
            bind-key -T copy-mode-vi 'V' send -X select-line
            bind-key -T copy-mode-vi 'y' send -X copy-selection-and-cancel
            bind-key -T copy-mode-vi 'q' send -X cancel
            bind-key -T copy-mode-vi Escape send -X cancel
            # unbind p
            # bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xsel -i -p && xsel -o -p | xsel -i -b"
            # bind-key p run "xsel -o | tmux load-buffer - ; tmux paste-buffer"
          '';
      };
    };
  };
}
