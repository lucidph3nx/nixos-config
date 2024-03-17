{ config, pkgs, ... }:

{
  programs.zsh = {
  	enable = true;

    history = {
      size = 10000;
      expireDuplicatesFirst = true;
    };
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
  home.file = {
    # config file for powerlevel10k
    ".config/zsh/p10k".source = ./files/p10k.zsh;
  };
}
