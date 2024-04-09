{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    package = pkgs.neovim-nightly;
    extraLuaPackages = ps: [ ps.magick ];
  };
  xdg.desktopEntries.nvim.noDisplay = true;
}
