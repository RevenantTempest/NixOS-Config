{ pkgs, ... }:
{
  services.xserver = {
    enable = true;
    videoDrivers = [ "amdgpu" ];
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    settings.General.DisplayServer = "wayland";
  };

  programs.labwc.enable = true;
  services.desktopManager.plasma6.enable = true;
  programs.xwayland.enable = true;

  xdg.portal = {
    enable = true;
    config.common.default = [ "gtk" ];
    config.plasma.default = [ "kde" ];
    config.labwc.default = [ "wlr" "gtk" ];
  };

  environment.variables = {
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
    KWIN_DRM_ALLOW_TEAR = "1";
    NIXOS_OZONE_WL = "1";
  };
}
