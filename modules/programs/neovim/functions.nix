{...}: {
  # some lua functions that don't escape well
  home-manager.users.ben.programs.neovim = {
    extraLuaConfig = builtins.readFile ./functions.lua;
  };
}
