{ pkgs, lib, ... }:

{
  home.packages = [
    (let
      pname = "prospect-mail";
      version = "0.5.2";
      name = "${pname}-${version}";
      src = pkgs.fetchurl {
        url =
          "https://github.com/julian-alarcon/prospect-mail/releases/download/v${version}/Prospect-Mail-${version}.AppImage";
        sha256 = "sha256-K106VkI/jPWnHqsWMWAKbzQyG5r0h+L3sufh4ZxkqIQ=";
      };
      appimageContents = pkgs.appimageTools.extractType1 { inherit name src; };
    in pkgs.appimageTools.wrapType1 {
      inherit name src;
      extraPkgs = pkgs.appimageTools.defaultFhsEnvArgs.multiPkgs;
      extraInstallCommands = ''
            mv $out/bin/${name} $out/bin/${pname}
            install -m 444 -D ${appimageContents}/${pname}.desktop $out/share/applications/${pname}.desktop
            install -m 444 -D ${appimageContents}/${pname}.png $out/share/icons/hicolor/512x512/apps/${pname}.png
            substituteInPlace $out/share/applications/${pname}.desktop \
              --replace 'Exec=AppRun --no-sandbox %U' 'Exec=${pname} %U'
          '';
    })
  ];
  xdg.desktopEntries = {
      prospect-mail = {
        name = "Outlook";
        genericName = "mail";
        exec = "prospect-mail %U";
        icon = "ms-outlook";
        categories = [ "Network" "Mail" "Office"];
      };
  };
}
