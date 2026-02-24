{ config, pkgs, pkgs-unstable, username, homeDirectory, configDirectory, inputs, lib, ... }:

{
  home = {
    inherit username homeDirectory;
    stateVersion = "25.11";
  };

  imports = [

  ];


  # Fixes "small words" in GTK apps like Faugus Launcher
  gtk = {
    enable = true;
    font = {
      name = "Noto Sans";
      size = 12;
    };
  };

  programs.firefox = {
    enable = true;
    profiles.nate = {
      settings = {
        # UI Scaling (equivalent to --force-device-scale-factor=1.25)
        "layout.css.devPixelsPerPx" = "2";

        # Wayland
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "widget.use-xdg-desktop-portal.mime-handler" = 1;

        # Hardware acceleration
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.force-enabled" = true;
        "gfx.webrender.all" = true;
        "gfx.webrender.compositor" = true;
      };
    };
  };


  home.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
    GDK_DPI_SCALE = "1.25";
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };


  programs.git.enable = true;


}
