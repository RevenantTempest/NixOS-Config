{ vars, pkgs, ... }:
{
  home = {
    username = vars.user.name;
    homeDirectory = vars.user.home;
    stateVersion = vars.sys.stateVersion;
  };

  programs.firefox = {
    enable = true;
    profiles.${vars.user.name} = {
      settings = {
        "layout.css.devPixelsPerPx" = "2";
        "media.ffmpeg.vaapi.enabled" = true;
      };
    };
  };

  home.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    NIXOS_OZONE_WL = "1";
  };

  programs.git.enable = true;
}
