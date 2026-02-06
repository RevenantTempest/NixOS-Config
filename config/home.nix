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

  home.sessionVariables = {
    GDK_DPI_SCALE = "1.25";
    NIXOS_OZONE_WL = "1";
  };

  # --- Labwc Configuration ---

  # Combined Autostart (Only one block allowed)
  # 3. Update autostart to just run 'quickshell'
  xdg.configFile."labwc/autostart".text = ''
    sleep 1 && quickshell &
  '';

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

  # --- Quickshell Configuration ---

xdg.configFile."quickshell/default/shell.qml".text = ''
    import QtQuick
    import Quickshell
    import Quickshell.Wayland

    ShellRoot {
        WaylandSurfaceWindow {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: 40

            layerShell.layer: LayerShell.LayerTop
            layerShell.namespace: "topbar"

            Rectangle {
                anchors.fill: parent
                color: "#1a1b26"

                Text {
                    anchors.centerIn: parent
                    text: "Quickshell basic bar"
                    color: "white"
                    font.pixelSize: 16
                }
            }
        }
    }
  '';

}
