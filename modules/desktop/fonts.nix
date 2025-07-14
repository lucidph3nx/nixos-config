{pkgs, ...}: {
  config = {
    fonts = {
      fontDir.enable = true;
      packages = [
        pkgs.noto-fonts
        pkgs.noto-fonts-color-emoji
        pkgs.nerd-fonts.jetbrains-mono
        pkgs.quicksand
      ];
      fontconfig = {
        enable = true;
        defaultFonts = {
          serif = ["Quicksand" "JetBrainsMono Nerd Font"];
          sansSerif = ["Quicksand" "JetBrainsMono Nerd Font"];
          monospace = ["JetBrainsMono Nerd Font"];
          emoji = ["Noto Color Emoji"];
        };
      };
    };
  };
}
