{ config, pkgs, lib, ... }:

{
  programs.zsh = {
  	enable = true;

    history = {
      size = 10000;
      expireDuplicatesFirst = true;
    };
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = lib.cleanSource ./files/p10k.zsh;
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
        "zsh-autosuggestions"
        "zsh-syntax-highlighting"
      ];
      theme = "powerlevel10k/powerlevel10k";
    };
    initExtra = ''
      # Custom keybindings
      bindkey -s ^f "cli.tmux.projectSessioniser\n"
      bindkey -s ^s "cli.tmux.sshHostSessioniser\n"
      bindkey -s ^k "k9s --headless\n"
      bindkey -s ^v "nvim\n"
      bindkey -s ^p "python\n"
      # Extra files to Source
      source ~/.config/zsh/p10k
    '';
  };
}
