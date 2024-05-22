{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}: let
  homeDir = config.home.homeDirectory;
in {
  options = {
    homeManagerModules.zsh.enable =
      lib.mkEnableOption "enables zsh";
  };
  config = lib.mkIf config.homeManagerModules.zsh.enable {
    programs.zsh = {
      enable = true;

      history = {
        size = 10000;
        expireDuplicatesFirst = true;
        path = "${homeDir}/.local/state/zsh/history";
      };
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
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
        # nixos rebuild switch
        nixrs = "sudo nixos-rebuild switch";
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
      };
      initExtra = ''
        # Custom keybindings
        bindkey -s ^v "nvim\n"
        bindkey -s ^p "python\n"
        # utils
        eval "$(direnv hook zsh)"
      '';
    };
  };
}
