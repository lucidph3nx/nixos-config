{
  config,
  pkgs,
  lib,
  ...
}: let
  homeDir = config.home.homeDirectory;
in {
  options = {
    homeManagerModules.zsh.enable =
      lib.mkEnableOption "enables zsh";
  };
  config = lib.mkIf config.homeManagerModules.zsh.enable {
    # We set ZDOTDIR at system level, so we don't need
    # to bootstrap the the zsh environment like this.
    home.file.".zshenv".enable = false;

    programs.zsh = {
      enable = true;
      dotDir = ".local/share/zsh";
      # source the zcompdump from persist if it exists
      # this is to speed up zsh startup in an impermanent environment
      completionInit = let
        dumpFile = "/persist/${homeDir}/.local/share/zsh/.zcompdump";
      in ''
        autoload -U compinit
        if [[ -f ${dumpFile} ]]; then
          compinit -d ${dumpFile}
        else
          compinit
        fi
      '';
      history = {
        size = 10000;
        expireDuplicatesFirst = true;
        path = "${homeDir}/.local/state/zsh/history";
      };
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      # zprof.enable = true; # for troubleshooting startup
      plugins = [
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
        {
          name = "powerlevel10k-config";
          src = lib.cleanSource ./files;
          file = "p10k.zsh";
        }
      ];
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "git-auto-fetch"
          "history"
          "vi-mode"
        ];
      };
      shellAliases = {
        # preserve env when using sudo
        # sudo = "sudo -E -s";
        # color terminals for ssh targets that don't know kitty
        ssh = "TERM=xterm-color ssh";
        # eza instead of ls
        ls = "eza";
        l = "eza -la";
        tree = "eza --tree -la";
        # ripgrep instead of grep
        grep = "rg";
        # nvim
        v = "nvim";
        # youtube music download script
        ytm-download = "yt-dlp  --add-metadata --format m4a --youtube-skip-dash-manifest -i -o '~/music/%(artist)s/%(album)s/%(title)s.%(ext)s' --sponsorblock-remove 'music_offtopic'";
        # git pull
        gP = "git pull";
      };
      initExtra = ''
        # Custom keybindings
        bindkey -s ^v "nvim\n"
        bindkey -s ^p "python\n"
        bindkey -s ^o "cli.tmux.projectSessioniser ~/documents/obsidian/personal-vault\n"
        # utils
        eval "$(direnv hook zsh)"
      '';
    };
    home.persistence."/persist/home/ben" = {
      directories = [
        ".local/share/zsh"
      ];
    };
  };
}
