{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nixModules.cli-tools.enable =
      lib.mkEnableOption "Add default cli tools";
  };
  config = lib.mkIf config.nixModules.cli-tools.enable {
    environment.systemPackages = with pkgs; [
      age
      bitwarden-cli
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
