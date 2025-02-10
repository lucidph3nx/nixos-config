{pkgs, ...}: {
  config = {
    fonts.fontDir.enable = true;
    fonts.packages = [
      pkgs.noto-fonts
      pkgs.noto-fonts-color-emoji
      pkgs.nerd-fonts.jetbrains-mono
    ];
  };
}
