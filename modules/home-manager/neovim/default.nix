{ config, lib, pkgs, inputs, ... }:

{
  options = {
    homeManagerModules.neovim.enable =
      lib.mkEnableOption "Set up Neovim";
  };
  imports = [
    ./abbreviations.nix
    ./autocmd.nix
    ./functions.nix
    ./keymaps.nix
    ./options.nix
    ./plugins
  ];
  config = lib.mkIf config.homeManagerModules.neovim.enable {
    home.sessionVariables.EDITOR = "nvim";
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      # package = pkgs.neovim-nightly;
    };
    # persistance conditional on isLinux, TODO: probably need to make this more specific in future 
    home.persistence."/persist/home/ben" = lib.mkIf pkgs.stdenv.isLinux {
      directories = [
        ".config/nvim/spell"
      ];
    };
  };
}
