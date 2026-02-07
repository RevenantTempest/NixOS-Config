{ config, pkgs, ... }:

let
  qml = ''
    import QtQuick 2.15
    import QtQuick.Layouts 1.15
    import Quickshell
    import Quickshell.Wayland

    PanelWindow {
      anchors {
        bottom: true
        left: true
        right: true
      }

      // Increased height slightly to 50 to give more breathing room
      height: 50
      exclusionMode: ExclusionMode.Exclusive
      color: "transparent"

      Rectangle {
        anchors.fill: parent
        color: "#1a1b26"
        opacity: 0.98

        RowLayout {
          // Use anchors.fill with margins to ensure it stays INSIDE the rectangle
          anchors.fill: parent
          anchors.leftMargin: 12
          anchors.rightMargin: 12
          spacing: 8

          // 1. Launcher (Bottom Left)
          Rectangle {
            Layout.preferredWidth: 44
            Layout.preferredHeight: 34
            Layout.alignment: Qt.AlignVCenter // Force vertical centering
            radius: 6
            color: "#24283b"

            Text {
              anchors.centerIn: parent
              text: "≡"
              color: "#7aa2f7"
              font.pixelSize: 20
            }

            MouseArea {
              anchors.fill: parent
              onClicked: console.log("Launcher clicked")
            }
          }

          // 2. Taskbar (Centered to the Left)
          Row {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillHeight: true
            spacing: 6

            Repeater {
              model: [ "firefox", "discord", "steam" ]
              delegate: Rectangle {
                // Ensure delegate height doesn't exceed the bar height
                width: 120; height: 34; radius: 6
                anchors.verticalCenter: parent.verticalCenter
                color: "#2a2d3a"
                border.color: "#414868"
                border.width: 1

                Text {
                  anchors.centerIn: parent
                  text: modelData
                  color: "white"
                  font.pixelSize: 12
                }
              }
            }
          }

          // 3. Flexible Spacer
          Item {
            Layout.fillWidth: true
          }

          // 4. Widgets (Right Side)
          RowLayout {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            spacing: 15

            Text {
              color: "#c0caf5"
              font.pixelSize: 13
              font.bold: true
              text: Qt.formatDateTime(new Date(), "hh:mm AP")
            }
          }
        }
      }
    }
  '';
in
{
  # ... (rest of the file remains the same as the previous working version)
  home.packages = [ pkgs.quickshell ];
  xdg.configFile."quickshell/default/shell.qml".text = qml;

  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell Wayland shell (user)";
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.quickshell}/bin/quickshell";
      Restart = "on-failure";
      Environment = [
        "QT_QPA_PLATFORM=wayland"
        "XDG_CURRENT_DESKTOP=labwc"
      ];
    };
    Install = { WantedBy = [ "default.target" ]; };
  };
}
