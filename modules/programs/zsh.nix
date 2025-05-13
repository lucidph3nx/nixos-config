{
  config,
  pkgs,
  lib,
  ...
}: let
  homeDir = config.home-manager.users.ben.home.homeDirectory;
in {
  options = {
    nx.programs.zsh.enable =
      lib.mkEnableOption "enables zsh"
      // {
        default = true;
      };
  };
  config = lib.mkIf config.nx.programs.zsh.enable {
    # zsh bootstrap
    programs.zsh = {
      enable = true;
      shellInit = ''
        export ZDOTDIR=$HOME/.local/share/zsh
      '';
    };
    home-manager.users.ben = {
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
        autosuggestion = {
          enable = true;
          highlight = "fg=${config.theme.grey1}";
        };
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
          {
            name = "vi-mode";
            src = pkgs.zsh-vi-mode;
            file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
          }
          {
            name = "zsh-history-substring-search";
            src = pkgs.zsh-history-substring-search;
            file = "share/zsh-history-substring-search/zsh-history-substring-search.zsh";
          }
        ];
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
          ytm-download = "yt-dlp  --add-metadata --format m4a --youtube-skip-dash-manifest -i -o '~/music/%(artist)s/%(album)s/%(title)s.%(ext)s' --sponsorblock-remove 'music_offtopic' --";
          # git aliases
          gP = "git pull";
          gcb = "git checkout -b";
          # history search
          hs = "history | grep";
        };
        sessionVariables = {
          # these interfere with my keybindings below
          ZVM_INIT_MODE = "sourcing";
        };
        initContent = let
          initExtra = lib.mkOrder 1000 ''
            # zsh-history-substring-search configuration
            bindkey '^[[A' history-substring-search-up # or '\eOA'
            bindkey '^[[B' history-substring-search-down # or '\eOB'
            HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

            # Custom keybindings
            bindkey -s ^v "nvim\n"
            bindkey -s ^p "python\n"
            bindkey -s ^o "cli.tmux.projectSessioniser ~/documents/obsidian\n"
            bindkey -s ^f "cli.tmux.projectSessioniser\n"
            # utils
            eval "$(direnv hook zsh)"
          '';
        in
          lib.mkMerge [initExtra];
      };
      home.persistence."/persist/home/ben" = {
        directories = [
          ".local/share/zsh"
          ".local/state/zsh"
        ];
      };
    };
  };
}
