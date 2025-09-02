// WorkspacesBar.qml
import QtQuick
import Quickshell
import Quickshell.Hyprland

Rectangle {
    id: root
    color: "transparent"

    // ---- API ---------------------------------------------------------------
    property bool vertical: true
    property int count: 10
    property real cell: 20
    property real gap: 8
    property real radius: Math.round(cell * 0.22)

    property color activeColor: "#00ffff"
    property color inactiveColor: "transparent"
    property color textActiveColor: "#000000"
    property color textInactiveColor: activeColor

    property int currentWorkspace: 1

    // NEW: centralize padding so we can size correctly
    property real pad: 5

    readonly property real _contentExtent: (count * cell) + Math.max(0, count - 1) * gap
    // include padding in implicit size so parents/layouts get the right box
    implicitWidth:  vertical ? (cell + 2*pad)       : (_contentExtent + 2*pad)
    implicitHeight: vertical ? (_contentExtent + 2*pad) : (cell + 2*pad)

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name && event.name.includes("workspace")) Qt.callLater(updateCurrentWorkspace)
        }
    }
    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() { Qt.callLater(updateCurrentWorkspace) }
    }

    function updateCurrentWorkspace() {
        try {
            const wsList = Hyprland.workspaces.values
            for (let i = 0; i < wsList.length; i++) {
                const ws = wsList[i]
                if (ws.focused === true) { currentWorkspace = ws.id; break }
            }
        } catch (e) {}
    }

    Component.onCompleted: updateCurrentWorkspace()

    Flow {
        id: strip
        anchors.centerIn: parent
        spacing: root.gap
        flow: root.vertical ? Flow.TopToBottom : Flow.LeftToRight
        padding: root.pad

        // IMPORTANT: include padding so Flow doesn’t wrap
        width:  root.vertical ? (root.cell + 2*root.pad)       : (root._contentExtent + 2*root.pad)
        height: root.vertical ? (root._contentExtent + 2*root.pad) : (root.cell + 2*root.pad)

        Repeater {
            model: root.count
            Rectangle {
                width: root.cell
                height: root.cell
                property bool active: (index + 1) === root.currentWorkspace
                color: active ? root.activeColor : root.inactiveColor
                scale: 1.0

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Hyprland.dispatch("workspace " + (index + 1))
                    onEntered: parent.scale = 1.08
                    onExited: parent.scale = 1.0
                }
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                Text {
                    anchors.centerIn: parent
                    text: (index + 1).toString()
                    color: parent.active ? root.textActiveColor : root.textInactiveColor
                    font.pixelSize: Math.max(10, root.cell * 0.4)
                    font.bold: parent.active
                    font.family: "Inter, sans-serif"
                }
            }
        }
    }
}
