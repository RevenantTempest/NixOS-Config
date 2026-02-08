{ config, pkgs, ... }:

let
  taskbarQML = ''
    import QtQuick
    import QtQuick.Controls
    import QtQuick.Layouts
    import Quickshell
    import Quickshell.Wayland

    PanelWindow {
        id: panel
        anchors {
            bottom: true
            left: true
            right: true
        }
        height: 48
        exclusionMode: ExclusionMode.Exclusive
        color: "#1a1b26"

        property var toplevelManager: Quickshell.Wayland.ToplevelManager

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 12

            // 1. Application Launcher Button
            Button {
                id: launcherButton
                contentItem: Text {
                    text: "󱄅"
                    font.pixelSize: 24
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: launcherButton.hovered ? "#3d59a1" : "transparent"
                    radius: 4
                }
                onClicked: {
                    console.log("Attempting to launch faugus-launcher...");
                    // Use Qt's application launching mechanism
                    Qt.openUrlExternally("exec://faugus-launcher");
                }
            }

            // 2. Task List (Centered-Left)
            Row {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: toplevelManager.toplevels
                    delegate: Button {
                        width: 160
                        height: 36

                        contentItem: Text {
                            text: modelData.title || "Window"
                            color: "white"
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignLeft
                            leftPadding: 8
                        }

                        background: Rectangle {
                            color: modelData.active ? "#3d59a1" : (parent.hovered ? "#2e3440" : "#24283b")
                            radius: 4
                            border.color: modelData.active ? "#7aa2f7" : "transparent"
                            border.width: 1
                        }

                        onClicked: modelData.focus()
                    }
                }
            }

            // 3. System Tray / Widgets Area (Right)
            RowLayout {
                spacing: 15

                // Clock & Date
                Column {
                    Text {
                        text: Qt.formatDateTime(new Date(), "hh:mm:ss")
                        color: "white"
                        font.pixelSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                    }
                    Text {
                        text: Qt.formatDateTime(new Date(), "ddd, MMM d")
                        color: "#a9b1d6"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }
    }
  '';
in
{
  # Write the QML file
  xdg.configFile."quickshell/default/taskbar.qml".source = pkgs.writeText "taskbar.qml" taskbarQML;

  # Only install quickshell here
  home.packages = with pkgs; [
    quickshell
  ];

  systemd.user.services.quickshell-taskbar = {
    Unit = {
      Description = "Custom Quickshell Taskbar";
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.quickshell}/bin/quickshell --path ${config.home.homeDirectory}/.config/quickshell/default/taskbar.qml";
      Restart = "on-failure";
      Environment = [
        "QT_QPA_PLATFORM=wayland"
        "XDG_CURRENT_DESKTOP=labwc"
        "QML2_IMPORT_PATH=${pkgs.quickshell}/lib/qt-6/qml"
      ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
