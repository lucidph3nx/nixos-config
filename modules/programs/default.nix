{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./anki.nix
    ./bitwarden.nix
    ./calibre.nix
    ./chromium.nix
    ./cura-appimage.nix
    ./darktable.nix
    ./dragon-drop.nix
    ./fastfetch.nix
    ./firefox
    ./git.nix
    ./homeAutomation.nix
    ./k9s.nix
    ./kitty.nix
    ./kubetools.nix
    ./lf.nix
    ./libreoffice.nix
    ./mpv.nix
    ./ncmpcpp.nix
    ./neovim
    ./nh.nix
    ./obsidian.nix
    ./picard.nix
    ./plexamp.nix
    ./podman.nix
    ./python.nix
    ./qutebrowser
    ./signal.nix
    ./ssh.nix
    ./tmux.nix
    ./tmuxSessioniser.nix
    ./vimiv.nix
    ./webcord.nix
    ./zathura.nix
    ./zsh.nix
  ];
  options = {
    nx.programs = {
      # Define the available browsers as an enum option
      defaultWebBrowser = lib.mkOption {
        default = "qutebrowser";
        type = lib.types.enum ["firefox" "qutebrowser"];
        description = "Default web browser to use.";
      };

      # Generate a structured object based on the selected browser
      defaultWebBrowserSettings = lib.mkOption {
        default = {
          name = "qutebrowser";
          cmd = "qutebrowser";
          newWindowCmd = "qutebrowser --target window";
        };
        type = lib.types.attrs;
        internal = true; # This is generated dynamically, not set directly
      };
    };
  };
  config = let
    browserSettings = {
      firefox = {
        name = "firefox";
        cmd = "firefox";
        newWindowCmd = "firefox --new-window";
      };
      qutebrowser = {
        name = "qutebrowser";
        cmd = "qutebrowser";
        newWindowCmd = "qutebrowser --target window";
      };
    };
  in {
    nx.programs.defaultWebBrowserSettings =
      lib.mkDefault
      (lib.attrByPath [config.nx.programs.defaultWebBrowser] {} browserSettings);
    home-manager.users.ben = {
      # not sure of a better place to put this
      xdg.mimeApps.enable = true;
      # some default programs that require no configuration
      home.packages = with pkgs; [
        age
        cachix
        curl
        dig
        direnv
        dust
        eza
        fzf
        fzy
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
      ];
    };
  };
}
