{ config, lib, pkgs, inputs, ... }:

{
  options = {
    homeManagerModules.neovim.enable =
      lib.mkEnableOption "Set up Neovim";
  };
  imports = [
    ./autocmd.nix
    ./keymaps.nix
    ./options.nix
    ./plugins
  ];
  config = lib.mkIf config.homeManagerModules.neovim.enable {
    home.packages = with pkgs; [
      alejandra
    ];
    home.sessionVariables.EDITOR = "nvim";

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      package = pkgs.neovim-nightly;
    };
  };
}
