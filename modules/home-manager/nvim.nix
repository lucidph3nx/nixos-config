{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
    extraLuaPackages = ps: [ ps.magick ];
  };
}
