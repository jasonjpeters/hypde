import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: panel

    screen: Quickshell.screens.find(s => s.name === "Virtual-1")
    
    WlrLayershell.namespace: "quickshell:bar:blue"
    WlrLayershell.layer: WlrLayer .Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    color: "transparent"

    anchors.top: true
    anchors.left: true
    anchors.bottom: true

    implicitWidth: 30

    margins.top: 0
    margins.left: 0
    margins.right: 0

    Rectangle {
        id: bar
        anchors.fill: parent
        color: "#1a1a1a"
        opacity: 0.7
        radius: 0
        visible: true

        Loader {
            anchors.left: parent.left
            source: "components/Workspaces.qml"
        }
    }
}
