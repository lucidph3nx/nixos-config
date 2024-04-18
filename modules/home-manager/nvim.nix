{ pkgs, ... }:

{
  home.packages = with pkgs; [
    alejandra
    nodejs_20
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
