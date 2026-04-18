{ pkgs, pkgs-unstable, vars, plasma-manager, ... }:
{
  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    settings.General.DisplayServer = "wayland";
  };

  services.desktopManager.plasma6.enable = true;
  programs.xwayland.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config.common.default = [ "gtk" ];
    config.plasma.default = [ "kde" ];
  };

  services.dbus.enable = true;

  environment.variables = {
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "1";
    KWIN_DRM_ALLOW_TEAR = "1";
    NIXOS_OZONE_WL = "1";
    XCURSOR_SIZE = "30";
  };



  # Swaylock & Effects
  home-manager.users.${vars.user.name} = {
  };

# Display-related tools
  environment.systemPackages = with pkgs; [


  # Unstable Packages
  ] ++ (with pkgs-unstable; [


  ]);
}
