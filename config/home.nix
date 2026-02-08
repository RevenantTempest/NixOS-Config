{ config, pkgs, pkgs-unstable, username, homeDirectory, configDirectory, noctalia, lib, ... }:

{
  home = {
    inherit username homeDirectory;
    stateVersion = "25.11";
  };

  imports = [
    ./quickshell/bar/taskbar.nix
    noctalia.homeModules.default
  ];

  # Fixes "small words" in GTK apps like Faugus Launcher
  gtk = {
    enable = true;
    font = {
      name = "Noto Sans";
      size = 12;
    };
  };

  programs.git.enable = true;

  home.sessionVariables = {
    GDK_DPI_SCALE = "1.25";
    NIXOS_OZONE_WL = "1";
  };



  # Labwc Right-click Menu
  xdg.configFile."labwc/menu.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <openbox_menu>
      <menu id="root-menu" label="Labwc">
        <item label="Terminal"><action name="Execute" command="konsole" /></item>
        <item label="Web Browser"><action name="Execute" command="google-chrome-stable" /></item>
        <item label="Exit"><action name="Exit" /></item>
      </menu>
    </openbox_menu>
  '';


  #labwc Monitor Configuration
  xdg.configFile."labwc/output".text = ''
    # Main Monitor (Center)
    # Positioned at 0,0 as the anchor
    DP-1 res 3840x2160@240 pos 0 0

    # Second Monitor (Left of Center)
    # X is -3840 to move it one full screen width to the left
    DP-3 res 3840x2160@144 pos -3840 0

    # Third Monitor (On Top of Center)
    # Y is -2160 to move it one full screen height UP
    HDMI-A-1 res 3840x2160@60 pos 0 -2160
  '';



  # --- Noctalia Quickshell Configuration ---
  programs.noctalia-shell = {
    enable = true;
    settings = {
      bar = {
        density = "compact";
        position = "bottom";
        showCapsule = false;
        widgets = {
          left = [
            { id = "ControlCenter"; useDistroLogo = true; }
            { id = "Network"; }
            { id = "Bluetooth"; }
          ];
          center = [
            { hideUnoccupied = false; id = "Workspace"; labelMode = "none"; }
          ];
          right = [
            { alwaysShowPercentage = false; id = "Battery"; warningThreshold = 30; }
            {
              formatHorizontal = "HH:mm";
              formatVertical = "HH mm";
              id = "Clock";
              useMonospacedFont = true;
              usePrimaryColor = true;
            }
          ];
        };
      };
      colorSchemes.predefinedScheme = "Monochrome";
      general = {
        avatarImage = "${homeDirectory}/.face";
        radiusRatio = 0.2;
      };
      location = {
        monthBeforeDay = true;
        name = "Detroit, USA";
      };
    };
  };

  # --- Labwc Configuration ---

  # Combined Autostart (Only one block allowed)
  xdg.configFile."labwc/autostart".text = ''
    #sleep 1 && systemctl --user start noctalia-shell
    sleep 1
  '';


}
