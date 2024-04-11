{ pkgs, ... }:

{
  home.packages = with pkgs; [
    alejandra
  ];
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    package = pkgs.neovim-nightly;
    extraLuaPackages = ps: [ ps.magick ];
  };
  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
