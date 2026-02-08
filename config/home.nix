{ config, pkgs, pkgs-unstable, username, homeDirectory, configDirectory, lib, inputs, ... }:

{
  home = {
    inherit username homeDirectory;
    stateVersion = "25.11";
  };

  imports = [
    inputs.dankMaterialShell.homeModules.dank-material-shell
  ];

  # Fixes "small words" in GTK apps like Faugus Launcher
  gtk = {
    enable = true;
    font = {
      name = "Noto Sans";
      size = 12;
    };
  };


  home.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
    GDK_DPI_SCALE = "1.25";
    NIXOS_OZONE_WL = "1";
  };

  home.packages = with pkgs; [
    inputs.dankMaterialShell.packages.${pkgs.system}.default
  ];

  programs.git.enable = true;

  # Dank Material Shell
  programs.dank-material-shell = {
    enable = true;
    enableSystemMonitoring = true;
    dgop.package = inputs.dgop.packages.${pkgs.system}.default;
    # Optional: Customize settings
    settings = {
      # Example settings (check Dank Material Shell docs for full options)
      panel = {
        position = "bottom";
        height = 48;
      };
      workspace = {
        count = 5;
      };
    };
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



  # --- Labwc Configuration ---

  # Combined Autostart (Only one block allowed)
  xdg.configFile."labwc/autostart".text = ''
    #sleep 1
  '';


}
