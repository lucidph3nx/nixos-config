{
  config,
  lib,
  ...
}: {
  options = {
    homeManagerModules.thunderbird.enable =
      lib.mkEnableOption "enables thunderbird";
  };
  config = lib.mkIf config.homeManagerModules.thunderbird.enable {
    programs.thunderbird = {
      enable = true;
    };
    # home.persistence."/persist/home/ben" = {
    #   directories = [
    #     ".config/thunderbird"
    #   ];
    # };
  };
}
