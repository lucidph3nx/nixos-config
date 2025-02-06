{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nx.programs.dragon-drop.enable =
      lib.mkEnableOption "enables dragon-drop / xdragon"
      // {
        default = true;
      };
  };
  config =
    lib.mkIf (config.nx.programs.dragon-drop.enable)
    {
      home-manager.users.ben = {
        home.packages = with pkgs; [xdragon];
        # lf integration
        programs.lf.extraConfig = lib.mkIf config.nx.programs.lf.enable ''
          # dragon
          cmd dragon-out %xdragon -a -x "$fx"
          cmd dragon-in ''${{
            files=$(xdragon -t -x)
            for file in $files
            do
              path=''${file#file://}
              name=$(basename "$path")
              mv "$path" "$(pwd)/$name"
            done
          }}
          map do dragon-out
          map di dragon-in
        '';
      };
    };
}
