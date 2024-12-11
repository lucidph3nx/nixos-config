{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nixModules.cli-tools.enable =
      lib.mkEnableOption "Add default cli tools"
      // {
        default = true;
      };
  };
  config = lib.mkIf config.nixModules.cli-tools.enable {
    environment.systemPackages = with pkgs; [
      age
      cachix
      curl
      dig
      direnv
      dust
      eza
      fzf
      fzy
      gh
      htop
      imagemagick
      jnv
      jq
      killall
      openssl
      p7zip
      pdftk
      python3Full
      ripgrep
      sops
      unrar
      unzip
      xdg-utils
      yq-go
      yt-dlp
      zsh
    ];
  };
}
