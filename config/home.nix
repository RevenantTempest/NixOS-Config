{ vars, pkgs, config, ... }:
{
  imports = [
    ./programs/standard/programming.nix
  ];

  home = {
    username = vars.user.name;
    homeDirectory = vars.user.home;
    stateVersion = vars.sys.stateVersion;

  };

  services.kanshi = {
    enable = true;
    systemdTarget = "";
  };

  programs.firefox = {
    enable = true;
    profiles.${vars.user.name} = {
      settings = {
        "layout.css.devPixelsPerPx" = "1.2";
        "media.ffmpeg.vaapi.enabled" = true;
      };
    };
  };

  home.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    NIXOS_OZONE_WL = "1";
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    # pick a theme you actually have installed
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    # omit size to avoid hardcoding
  };

  gtk = {
    enable = true;
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };

  programs.git.enable = true;
}
