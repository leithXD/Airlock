import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Services.Greetd
import Caelestia.Blobs
import Astra.Airlock
import M3Shapes
import "../services"

Rectangle {
    id: root

    property bool menuOpen: false
    property var options: []
    property var selectedValue
    property string selectedName
    property string title: "Avatar shape"
    property string subtitle: "Mask geometry"
    property int topRounding: 14
    property int dropdownHeight: 140

    signal optionSelected(var value, string name)

    Layout.fillWidth: true
    implicitHeight: menuOpen ? (48 + dropdownDrawer.implicitHeight) : 48
    topLeftRadius: root.topRounding
    topRightRadius: root.topRounding
    bottomLeftRadius: 4
    bottomRightRadius: 4
    clip: true

    Behavior on implicitHeight {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }

    color: hHover.hovered || root.menuOpen
        ? Colours.tPalette.m3surfaceContainerHighest
        : Colours.tPalette.m3surfaceContainerHigh
    Behavior on color { ColorAnimation { duration: 120 } }
    HoverHandler { id: hHover }

    Item {
        id: headerBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 48

        Column {
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.right: splitBtnContainer.left
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Text {
                width: parent.width
                text: root.title
                font.family: "Google Sans Flex"
                font.pointSize: 11
                font.weight: Font.Medium
                color: Colours.palette.m3onSurface
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: root.subtitle
                font.family: "Google Sans Flex"
                font.pointSize: 8
                color: Colours.palette.m3outline
                elide: Text.ElideRight
            }
        }

        Row {
            id: splitBtnContainer
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Rectangle {
                implicitHeight: 28
                implicitWidth: btnRow.implicitWidth + 16
                topLeftRadius: 14
                bottomLeftRadius: 14
                topRightRadius: 4
                bottomRightRadius: 4
                color: Colours.tPalette.m3primaryContainer

                StateLayer {
                    color: Colours.palette.m3onPrimaryContainer
                    onClicked: root.menuOpen = !root.menuOpen
                }

                RowLayout {
                    id: btnRow
                    anchors.centerIn: parent
                    spacing: 6

                    MaterialShape {
                        implicitSize: 14
                        shape: root.selectedValue
                        color: Colours.palette.m3onPrimaryContainer
                    }

                    Text {
                        text: root.selectedName
                        font.family: "Google Sans Flex"
                        font.pointSize: 9
                        font.weight: Font.Medium
                        color: Colours.palette.m3onPrimaryContainer
                    }
                }
            }

            Rectangle {
                implicitHeight: 28
                implicitWidth: 26
                topLeftRadius: 4
                bottomLeftRadius: 4
                topRightRadius: 14
                bottomRightRadius: 14
                color: Colours.tPalette.m3primaryContainer

                StateLayer {
                    color: Colours.palette.m3onPrimaryContainer
                    onClicked: root.menuOpen = !root.menuOpen
                }

                MaterialIcon {
                    anchors.centerIn: parent
                    text: "expand_more"
                    fontStyle.pointSize: 16
                    color: Colours.palette.m3onPrimaryContainer
                    rotation: root.menuOpen ? 180 : 0
                    Behavior on rotation { NumberAnimation { duration: 180 } }
                }
            }
        }
    }

    Item {
        id: dropdownDrawer
        anchors.top: headerBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        anchors.bottomMargin: 8
        implicitHeight: root.dropdownHeight
        visible: root.menuOpen

        VerticalFadeListView {
            id: listView
            anchors.fill: parent
            clip: true
            model: root.options
            spacing: 2
            fadeAmount: 0.15

            delegate: Rectangle {
                id: item
                required property var modelData
                required property int index

                width: listView.width
                implicitHeight: 32
                radius: 8

                readonly property bool isSelected: root.selectedValue === modelData.value

                color: itemState.containsMouse || item.isSelected
                    ? Colours.tPalette.m3primaryContainer
                    : "transparent"
                Behavior on color { ColorAnimation { duration: 100 } }

                function select() {
                    root.optionSelected(item.modelData.value, item.modelData.name);
                    root.menuOpen = false;
                }

                StateLayer {
                    id: itemState
                    onClicked: item.select()
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    MaterialShape {
                        implicitSize: 16
                        shape: item.modelData.value
                        color: item.isSelected
                            ? Colours.palette.m3onPrimaryContainer
                            : Colours.palette.m3primary
                    }

                    Text {
                        Layout.fillWidth: true
                        text: item.modelData.name
                        font.family: "Google Sans Flex"
                        font.pointSize: 9
                        font.weight: item.isSelected ? Font.Bold : Font.Normal
                        color: item.isSelected
                            ? Colours.palette.m3onPrimaryContainer
                            : Colours.palette.m3onSurface
                    }

                    MaterialIcon {
                        visible: item.isSelected
                        text: "check"
                        fontStyle.pointSize: 14
                        color: Colours.palette.m3onPrimaryContainer
                    }
                }

                TapHandler {
                    onTapped: item.select()
                }
            }
        }
    }
}