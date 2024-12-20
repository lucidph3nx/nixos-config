{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  home.file = {
    ".config/ags/style.scss" = with config.theme; {
      text =
        /*
        scss
        */
        ''
           $foreground: ${foreground};
           $primary: ${primary};
           $secondary: ${secondary};
           $red: ${red};
           $orange: ${orange};
           $yellow: ${yellow};
           $green: ${green};
           $aqua: ${aqua};
           $blue: ${blue};
           $purple: ${purple};
           $grey0: ${grey0};
           $grey1: ${grey1};
           $grey2: ${grey2};
           $statusline1: ${statusline1};
           $statusline2: ${statusline2};
           $statusline3: ${statusline3};
           $bg-dim: ${bg_dim};
           $bg0: ${bg0};
           $bg1: ${bg1};
           $bg2: ${bg2};
           $bg3: ${bg3};
           $bg4: ${bg4};
           $bg5: ${bg5};
           $bg-visual: ${bg_visual};
           $bg-red: ${bg_red};
           $bg-green: ${bg_green};
           $bg-blue: ${bg_blue};
           $bg-yellow: ${bg_yellow};


          .Workspaces {
            font-family: 'JetBrainsMono Nerd Font';
            font-size: 22px;
          }

          .Workspaces .workspace {
            min-width: 5rem;
            min-height: 5rem;
          }

          .Workspaces .workspace.focused {
            color: $bg0;
            background-color: $primary;
          }
          .Workspaces .workspace.notfocused {
            color: $foreground;
            background-color: $bg0;
          }
          .Workspaces .workspace.placeholder {
            color: $grey0;
            background-color: $bg0;
          }

          .FocusedClient {
            color: $foreground;
            background-color: $bg0;
            font-family: 'JetBrainsMono Nerd Font';
            font-size: 22px;
          }
          .FocusedClientContent {
            min-height: 5rem;
            min-width: 5rem;
          }

          .NowPlaying {
            color: $foreground;
            background-color: $bg0;
            font-family: 'JetBrainsMono Nerd Font';
            font-size: 22px;
            min-height: 5rem;
          }

          .Time {
            color: $bg0;
            background-color: $primary;
            font-family: 'JetBrainsMono Nerd Font';
            font-size: 22px;
            min-height: 5rem;
          }
          .EnvironmentSensors {
            color: $bg0;
            background-color: $primary;
            font-family: 'JetBrainsMono Nerd Font';
            font-size: 22px;
            min-height: 5rem;
          }
        '';
    };
  };
}
