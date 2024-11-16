{
  config,
  lib,
  pkgs,
  ...
}:
with config.theme; 
let 
  configDir = "${config.home.homeDirectory}/.config";
in {
  options = {
    homeManagerModules.wallpaper.enable = 
      lib.mkEnableOption "enables svg based dynamic wallpaper" 
      // {
      default = true;
    };
  };
  config = lib.mkIf config.homeManagerModules.wallpaper.enable {
    # convert the svg to a png at activaion time
    home.activation.renderWallpaper = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.imagemagick}/bin/convert ${configDir}/wallpaper-2800x1800.svg ${configDir}/wallpaper-2800x1800.png

    '';
    home.file.".config/wallpaper-2800x1800.svg" = {
      text = let
        colourbg = "${bg_dim}";
        colour1 = "${red}";
        colour2 = "${yellow}";
        colour3 = "${green}";
        colour4 = "${blue}";
        colour5 = "${purple}";
      in ''
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <svg
           width="2880"
           height="1800"
           viewBox="0 0 762 476.25"
           version="1.1"
           id="svg1"
           inkscape:version="1.3.2 (091e20ef0f, 2023-11-25)"
           sodipodi:docname="wallpaper-2880x1800.svg"
           xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
           xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
           xmlns="http://www.w3.org/2000/svg"
           xmlns:svg="http://www.w3.org/2000/svg">
          <sodipodi:namedview
             id="namedview1"
             pagecolor="#ffffff"
             bordercolor="#000000"
             borderopacity="0.25"
             inkscape:showpageshadow="2"
             inkscape:pageopacity="0.0"
             inkscape:pagecheckerboard="0"
             inkscape:deskcolor="#d1d1d1"
             inkscape:document-units="mm"
             inkscape:zoom="0.30921515"
             inkscape:cx="1112.494"
             inkscape:cy="465.69516"
             inkscape:window-width="1904"
             inkscape:window-height="1147"
             inkscape:window-x="0"
             inkscape:window-y="0"
             inkscape:window-maximized="1"
             inkscape:current-layer="layer2" />
          <defs
             id="defs1" />
          <g
             inkscape:groupmode="layer"
             id="layer2"
             inkscape:label="background">
            <rect
               style="fill:${colourbg};fill-opacity:1;stroke-width:0.880531"
               id="rect6"
               width="762"
               height="476.25"
               x="0"
               y="0" />
          </g>
          <g
             inkscape:label="rainbow"
             inkscape:groupmode="layer"
             id="layer1">
            <path
               d="m 761.65325,290.00607 -186.30852,186.30853 28.29388,-0.01 157.82447,-157.82448 z"
               style="fill:${colour5};stroke-width:2.83292"
               id="path22" />
            <path
               d="m 761.84342,261.53132 -214.79309,214.79309 28.2944,-0.01 186.30852,-186.30853 z"
               style="fill:${colour4};stroke-width:2.62435"
               id="path21" />
            <path
               d="m 762.03411,233.05606 -243.27818,243.27817 28.2944,-0.01 214.79309,-214.79309 z"
               style="fill:${colour3};stroke-width:4.33177"
               id="path20" />
            <path
               d="m 762.22428,204.58234 -271.76223,271.76171 28.29388,-0.01 243.27818,-243.27817 z"
               style="fill:${colour2};stroke-width:0.434521"
               id="path19" />
            <path
               d="m 762.41444,176.1076 -300.24627,300.24627 28.29388,-0.01 271.76223,-271.76171 z"
               style="fill:${colour1};stroke-width:0.583395"
               id="path18" />
          </g>
        </svg>
      '';
    };
  };
}
