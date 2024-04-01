{ config, pkgs, inputs, ... }:

{
  # workarounds
  # https://github.com/NixOS/nixpkgs/issues/281710#issuecomment-1987263584
  home.file.".mozilla/native-messaging-hosts" = {
    recursive = true;
    source = let
      nativeMessagingHosts = with pkgs; [
        tridactyl-native
      ];
    in pkgs.runCommandLocal "native-messaging-hosts" { } ''
      mkdir $out
      for ext in ${toString nativeMessagingHosts}; do
          ln -sLt $out $ext/lib/mozilla/native-messaging-hosts/*
      done
    '';
  };
  programs.firefox = {
  	enable = true;
    # not in 23.11
    # nativeMessagingHosts.packages = [
    #   pkgs.tridactyl-native
    # ];
    profiles.ben = {
      id = 0;
      name = "ben";
      isDefault = true;
      settings = {
        "signon.rememberSignons" = false; # Disable built-in password manager
      };
      extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
        augmented-steam
        bitwarden
        decentraleyes
        multi-account-containers
        protondb-for-steam
        reddit-enhancement-suite
        sponsorblock
        temporary-containers
        tridactyl
        ublock-origin
      ];
    };
  };
    xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };
}
