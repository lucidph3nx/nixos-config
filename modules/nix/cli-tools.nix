{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nx.cli-tools.enable =
      lib.mkEnableOption "Add default cli tools"
      // {
        default = true;
      };
  };
  config = lib.mkIf config.nx.cli-tools.enable {
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
      (python3.withPackages (python312Packages: [
        python312Packages.requests
      ]))
      ripgrep
      sops
      unrar
      unzip
      xdg-utils
      yq-go
      yt-dlp
    ];
  };
}
