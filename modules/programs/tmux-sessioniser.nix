{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  options = {
    nx.programs.tmuxSessioniser.enable = lib.mkEnableOption "enables tmuxSessioniser" // {
      default = true;
    };
  };
  config =
    lib.mkIf
      (
        config.nx.programs.tmuxSessioniser.enable
        # no point in installing if tmux is not
        && config.nx.programs.tmux.enable
      )
      {
        home-manager.users.ben = {
          # making sure scripts are on path if not set elsewhere
          home.sessionPath = [ "$HOME/.local/scripts" ];

          # This script returns a \n separated list of locations for tmuxSessioniser to open
          # they could be directories or 'locations' where every sub folder is available
          home.file.".local/scripts/cli.tmux.projectGetter" = {
            executable = true;
            text =
              # bash
              ''
                #!/bin/sh

                locations=(
                  "~/code"
                  # "~/.config"
                )
                specific_folders=(
                  # "~/.local/scripts/"
                  # "~/.ssh/"
                  "~/documents/obsidian/"
                )

                for location in "''${locations[@]}"; do
                  find "$(eval echo $location)" -mindepth 1 -maxdepth 1 -type d
                done
                for folder in "''${specific_folders[@]}"; do
                  find "$(eval echo $folder)" -mindepth 0 -maxdepth 0 -type d
                done
              '';
          };
          # This script opens a tmux session for a project directory
          # it can take an argument to open a specific directory
          # otherwise it uses the projectGetter script above
          # Note: it opens the target in neovim
          home.file.".local/scripts/cli.tmux.projectSessioniser" = {
            executable = true;
            text =
              let
                tmux = "${pkgs.tmux}/bin/tmux";
              in
              # bash
              ''
                #!/bin/sh

                if [[ $# -eq 1 ]]; then
                    selected=$1
                else
                    selected=$(cli.tmux.projectGetter | ${pkgs.fzy}/bin/fzy)
                fi

                if [[ -z $selected ]]; then
                    exit 0
                fi

                selected_name=$(basename "$selected" | tr . _)
                tmux_running=$(pgrep tmux)

                # set window title to be selected_name
                echo -ne "\033]0;''${selected_name}\007"

                # Check if the selected item is a file or if the directory contains a single file
                if [[ -f $selected ]]; then
                    # is a file, open it
                    selected_file="$selected"
                    selected="$(dirname "$selected")"
                else
                    # is a folder
                    file_count=$(find "$selected" -maxdepth 1 -type f | wc -l)
                    if [[ $file_count -eq 1 ]]; then
                        # only one file here, open it
                        selected_file=$(find "$selected" -maxdepth 1 -type f)
                    else
                      # if many files, but one of them is a README.md, open that
                      readme_file="$(find "$selected" -maxdepth 1 -type f -name "README.md")"
                      if [[ -n "$readme_file" ]]; then
                        selected_file="$readme_file"
                      else
                        selected_file=""
                      fi
                    fi
                fi

                # new session if not in tmux and tmux is not running
                if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
                    ${tmux} new-session -s $selected_name -c $selected -d
                    if [[ -n $selected_file ]]; then
                        ${tmux} send-keys -t $selected_name "nvim '$selected_file'" C-m
                    else
                        ${tmux} send-keys -t $selected_name "nvim" C-m
                    fi
                    ${tmux} attach-session -t $selected_name
                    exit 0
                fi

                # new session if not in tmux and tmux is running
                if ! ${tmux} has-session -t=$selected_name 2> /dev/null; then
                    ${tmux} new-session -ds $selected_name -c $selected
                    if [[ -n $selected_file ]]; then
                        ${tmux} send-keys -t $selected_name "nvim '$selected_file'" C-m
                    else
                        ${tmux} send-keys -t $selected_name "nvim" C-m
                    fi
                fi

                # attach to session if in tmux
                if [[ -n $TMUX ]]; then
                  ${tmux} switch-client -t $selected_name
                else
                  ${tmux} attach-session -t $selected_name
                fi
              '';
          };
        };
      };
}
