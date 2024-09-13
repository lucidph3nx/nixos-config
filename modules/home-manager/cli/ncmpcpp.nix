{
  config,
  pkgs,
  lib,
  ...
}: let
  homeDir = config.home.homeDirectory;
in {
  options = {
    homeManagerModules.ncmpcpp.enable =
      lib.mkEnableOption "enables ncmpcpp";
  };
  config =
    lib.mkIf (config.homeManagerModules.ncmpcpp.enable
      # no point in installing if mpd is not
      && config.homeManagerModules.mpd.enable)
    {
      programs.ncmpcpp = {
        enable = true;
        package = pkgs.ncmpcpp.override {visualizerSupport = true;};
        mpdMusicDir = "${homeDir}/music/";
        settings = {
          display_bitrate = "yes";
          user_interface = "alternative";
          visualizer_output_name = "my_fifo";
          visualizer_in_stereo = "yes";
          visualizer_type = "spectrum";
          main_window_color = 5;
          color1 = 3;
          color2 = 2;
          statusbar_color = 7;
          empty_tag_color = 7;
          playlist_display_mode = "classic";
          song_list_format = "%t $R %a   %l";
          now_playing_prefix = "$(green)$b";
          now_playing_suffix = "$/b$(end)";
          current_item_prefix = "$(green)$r";
          current_item_suffix = "$/r$(end)";
          current_item_inactive_column_prefix = "$5$r";
          media_library_primary_tag = "album_artist";
        };
        bindings = [
          {
            key = "l";
            command = "next_column";
          }
          {
            key = "h";
            command = "previous_column";
          }
          {
            key = "k";
            command = "scroll_up";
          }
          {
            key = "j";
            command = "scroll_down";
          }
          {
            key = "G";
            command = "move_end";
          }
          {
            key = "g";
            command = "move_home";
          }
          {
            key = "ctrl-u";
            command = "page_up";
          }
          {
            key = "ctrl-d";
            command = "page_down";
          }
          {
            key = "n";
            command = "next_found_item";
          }
          {
            key = "N";
            command = "previous_found_item";
          }
          {
            key = "+";
            command = "show_clock";
          }
          {
            key = "=";
            command = "volume_up";
          }
          {
            key = "-";
            command = "volume_down";
          }
          {
            key = "d";
            command = "delete_playlist_items";
          }
          {
            key = "v";
            command = "show_visualizer";
          }
          {
            key = "f";
            command = "change_browse_mode";
          }
          {
            key = "m";
            command = "show_media_library";
          }
          {
            key = "u";
            command = "update_database";
          }
          # unbinds
          {
            key = "left";
            command = "dummy";
          }
          {
            key = "right";
            command = "dummy";
          }
          {
            key = "x";
            command = "dummy";
          }
        ];
      };
    };
}
