{
  lib,
  # config,
  ...
}: {
  # options = {
  #   homeManagerModules = {
  #     # Define the available browsers as an enum option
  #     defaultWebBrowser = lib.mkOption {
  #       default = "qutebrowser";
  #       type = lib.types.enum ["firefox" "qutebrowser"];
  #       description = "Default web browser to use.";
  #     };
  #
  #     # Generate a structured object based on the selected browser
  #     defaultWebBrowserSettings = lib.mkOption {
  #       default = {
  #         name = "qutebrowser";
  #         cmd = "qutebrowser";
  #         newWindowCmd = "qutebrowser --target window";
  #       };
  #       type = lib.types.attrs;
  #       internal = true; # This is generated dynamically, not set directly
  #     };
  #   };
  # };
  imports = [
    ./desktopEnvironment
    ./scripts
  ];
  # config = let
  #   browserSettings = {
  #     firefox = {
  #       name = "firefox";
  #       cmd = "firefox";
  #       newWindowCmd = "firefox --new-window";
  #     };
  #     qutebrowser = {
  #       name = "qutebrowser";
  #       cmd = "qutebrowser";
  #       newWindowCmd = "qutebrowser --target window";
  #     };
  #   };
  # in {
    homeManagerModules = {
  #     defaultWebBrowserSettings =
  #       lib.mkDefault
  #       (lib.attrByPath [config.homeManagerModules.defaultWebBrowser] {} browserSettings);
      desktopEnvironment.enable = lib.mkDefault true;
    };
  #   xdg.mimeApps.enable = true;
  #   # Let Home Manager install and manage itself.
  #   programs.home-manager.enable = true;
  # };
}
