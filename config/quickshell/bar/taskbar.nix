{ config, pkgs, ... }:

let
  launcherBin = "${pkgs.faugus-launcher}/bin/faugus-launcher";

  taskbarQML = ''
    import QtQuick
    import QtQuick.Controls
    import QtQuick.Layouts
    import Quickshell
    import Quickshell.Wayland
    import Quickshell.Io

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

        property var toplevelManager: ToplevelManager

        // Property to hold the current time, updated by the timer
        property date currentTime: new Date()

        Timer {
            interval: 1000 // Update every second
            running: true
            repeat: true
            onTriggered: panel.currentTime = new Date()
        }

        Process {
            id: launcherProcess
            command: ["${launcherBin}"]
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 12

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
                onClicked: launcherProcess.running = true
            }

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

                        onClicked: {
                            if (modelData.active) {
                                if (modelData.hasOwnProperty("minimized")) {
                                    modelData.minimized = true;
                                }
                            } else {
                                if (modelData.hasOwnProperty("activate")) {
                                    modelData.activate();
                                } else if (modelData.hasOwnProperty("requestActivate")) {
                                    modelData.requestActivate();
                                }
                            }
                        }
                    }
                }
            }

            // Updated Clock Area
            RowLayout {
                spacing: 15
                Column {
                    Text {
                        // Bind to the currentTime property
                        text: Qt.formatDateTime(panel.currentTime, "hh:mm:ss")
                        color: "white"
                        font.pixelSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                    }
                    Text {
                        // Bind to the currentTime property
                        text: Qt.formatDateTime(panel.currentTime, "ddd, MMM d")
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
  xdg.configFile."quickshell/default/taskbar.qml".source = pkgs.writeText "taskbar.qml" taskbarQML;

  home.packages = with pkgs; [
    quickshell
    faugus-launcher
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
