{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    homeManagerModules.prospect-mail.enable =
      lib.mkEnableOption "enables prospect-mail";
  };
  config = lib.mkIf config.homeManagerModules.prospect-mail.enable {
    home.packages = [
      (let
        pname = "prospect-mail";
        version = "0.5.2";
        name = "${pname}-${version}";
        src = pkgs.fetchurl {
          url = "https://github.com/julian-alarcon/prospect-mail/releases/download/v${version}/Prospect-Mail-${version}.AppImage";
          sha256 = "sha256-Fgn7djbtROAUT0S/zEIhLsVWme1T02qa81j+iVmBxNE=";
        };
      in
        pkgs.appimageTools.wrapType1 {
          inherit name src;
          extraPkgs = pkgs.appimageTools.defaultFhsEnvArgs.multiPkgs;
          extraInstallCommands = ''
            mv $out/bin/${name} $out/bin/${pname}
          '';
        })
    ];
    xdg.desktopEntries = lib.mkIf pkgs.stdenv.isLinux {
      prospect-mail = {
        name = "Outlook";
        genericName = "mail";
        exec = "prospect-mail %U";
        icon = "ms-outlook";
        categories = ["Network" "Office"];
      };
    };
  };
}
