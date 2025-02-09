{pkgs, ...}: {
  config = {
    fonts.fontDir.enable = true;
    fonts.packages = [
      pkgs.noto-fonts
      pkgs.nerd-fonts.jetbrains-mono
    ];
  };
}
