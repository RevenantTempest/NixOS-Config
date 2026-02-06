{ config, pkgs, pkgs-unstable, username, homeDirectory, configDirectory, ... }:

{
  home = {
    inherit username homeDirectory;
    stateVersion = "25.11";
  };

  # Fixes "small words" in GTK apps like Faugus Launcher
  gtk = {
    enable = true;
    font = {
      name = "Noto Sans";
      size = 12;
    };
  };

  programs.git.enable = true;

  # Minimal home.nix
  home.sessionVariables = {
    GDK_DPI_SCALE = "1.25";
    NIXOS_OZONE_WL = "1";
  };

  # Create the labwc config directory and autostart file
  xdg.configFile."labwc/autostart".text = ''
    # Start your Quickshell setup
    quickshell &

    # Set a wallpaper
    swaybg -m fill -i ${config.home.homeDirectory}/Pictures/wallpaper.jpg &
  '';

  # Create a basic labwc menu so you aren't stuck
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

  # 2. A Minimal Quickshell Bar (shell.qml)
  # This creates a simple blue bar at the top of the screen
  xdg.configFile."quickshell/shell.qml".text = ''
    import QtQuick
    import Quickshell
    import Quickshell.Wayland

    ShellRoot {
        VariantsWindow {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: 40

            WlrLayerShell.layer: WlrLayerShell.LayerTop
            WlrLayerShell.namespace: "topbar"

            Rectangle {
                anchors.fill: parent
                color: "#1a1b26" // Tokyo Night Dark

                Text {
                    anchors.centerIn: parent
                    text: "Quickshell is Running on Labwc!"
                    color: "white"
                    font.pixelSize: 16
                }
            }
        }
    }
  '';

}
