{ config, pkgs, lib, ... }:

{
  programs.zsh = {
  	enable = true;

    history = {
      size = 10000;
      expireDuplicatesFirst = true;
    };
    # autosuggestion.enable = true; # not in 23.11
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
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.4.0";
          sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
        };
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
    initExtra = ''
      # Custom keybindings
      bindkey -s ^f "cli.tmux.projectSessioniser\n"
      bindkey -s ^s "cli.tmux.sshHostSessioniser\n"
      bindkey -s ^k "k9s --headless\n"
      bindkey -s ^v "nvim\n"
      bindkey -s ^p "python\n"
    '';
  };
}
