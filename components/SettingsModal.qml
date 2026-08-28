pragma ComponentBehavior: Bound

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

// Morphing Settings Modal (Bottom-Left) matching Caelestia Nexus Settings layout:
// Section headers, connected M3 rounded cards, avatar shape scrollable split button,
// and perfectly aligned toggle switches with check/cross icons.
Item {
    id: root

    property bool isOpen: false
    property bool shapeMenuOpen: false
    property bool styleMenuOpen: false
    signal exitRequested()

    implicitWidth: 44
    implicitHeight: 44

    property real animDriver: 0

    readonly property var shapeOptions: [
        { name: "Cookie 9-Sided", value: MaterialShape.Cookie9Sided },
        { name: "Clamshell",      value: MaterialShape.ClamShell },
        { name: "Cookie 4-Sided", value: MaterialShape.Cookie4Sided },
        { name: "Cookie 6-Sided", value: MaterialShape.Cookie6Sided },
        { name: "Cookie 7-Sided", value: MaterialShape.Cookie7Sided },
        { name: "Cookie 12-Sided",value: MaterialShape.Cookie12Sided },
        { name: "Sunny",          value: MaterialShape.Sunny },
        { name: "Very Sunny",     value: MaterialShape.VerySunny },
        { name: "Soft Burst",     value: MaterialShape.SoftBurst },
        { name: "Circle",         value: MaterialShape.Circle },
        { name: "Pentagon",       value: MaterialShape.Pentagon },
        { name: "Gem",            value: MaterialShape.Gem },
        { name: "Arch",           value: MaterialShape.Arch },
        { name: "Arrow",          value: MaterialShape.Arrow },
        { name: "Pill",           value: MaterialShape.Pill },
        { name: "Triangle",       value: MaterialShape.Triangle },
        { name: "Fan",            value: MaterialShape.Fan },
        { name: "Oval",           value: MaterialShape.Oval }
    ]

    readonly property var menuOptions: [
        { name: "Classical", value: MaterialShape.Square },
        { name: "Locklike",      value: MaterialShape.ClamShell }
    ]

    BlobGroup {
        id: blobGroup
        color: Colours.tPalette.m3surfaceContainer
        smoothing: 24
        cornerFill: false
    }

    // ── Popup Modal Rect (Elevated above bottom-left button) ──────
    BlobRect {
        id: popupRect

        anchors.left: parent.left
        anchors.bottom: parent.bottom

        implicitWidth: parent.width
        implicitHeight: parent.height

        group: blobGroup
        radius: 20
        deformScale: 0.00001

        states: State {
            name: "open"
            when: root.isOpen

            PropertyChanges {
                popupRect.anchors.bottomMargin: 64
                popupRect.anchors.leftMargin: 0
                popupRect.implicitWidth: 350
                popupRect.implicitHeight: contentCol.implicitHeight + 28
                root.animDriver: 1
            }
        }

        transitions: Transition {
            NumberAnimation {
                properties: "bottomMargin,leftMargin,implicitWidth,implicitHeight"
                duration: 260
                easing.type: Easing.OutBack
                easing.overshoot: 1.10
            }
            NumberAnimation {
                property: "animDriver"
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        // Click catcher inside modal so clicking inside doesn't dismiss
        MouseArea {
            anchors.fill: parent
            enabled: root.isOpen
            onClicked: {}
        }

        // Popup Content
        Item {
            anchors.fill: parent
            anchors.margins: 14
            clip: true
            opacity: root.animDriver
            visible: opacity > 0

            ColumnLayout {
                id: contentCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: 2

                // ── Section 1 Header: Appearance & Display ────────
                Text {
                    text: "Appearance & Display"
                    font.family: "Google Sans Flex"
                    font.pointSize: 9
                    font.weight: Font.DemiBold
                    color: Colours.palette.m3onSurfaceVariant
                    Layout.leftMargin: 4
                    Layout.topMargin: 2
                    Layout.bottomMargin: 4
                }

                // ── Row 1: Avatar Shape (Scrollable Split-Button Dropdown) ──
                
                SplitDropdownRow {
                    Layout.fillWidth: true
                    menuOpen: root.shapeMenuOpen
                    onMenuOpenChanged: root.shapeMenuOpen = menuOpen
                    options: root.shapeOptions
                    selectedValue: Colours.avatarShape
                    selectedName: Colours.avatarShapeName
                    onOptionSelected: (value, name) => {
                        Colours.avatarShape = value;
                        Colours.avatarShapeName = name;
                    }
                }

                // menu style options

                SplitDropdownRow {
                    Layout.fillWidth: true
                    title: "Menu Style"
                    subtitle: "Greeter menu layout"
                    topRounding: 4
                    dropdownHeight: 75
                    menuOpen: root.styleMenuOpen
                    onMenuOpenChanged: root.styleMenuOpen = menuOpen
                    options: root.menuOptions
                    selectedValue: Colours.menuStyle
                    selectedName: Colours.menuStyleName
                    onOptionSelected: (value, name) => {
                        Colours.menuStyle = value;
                        Colours.menuStyleName = name;
                    }
                }

                // ── Row 2: 12-Hour Clock (Middle in Group) ──────────
                Rectangle {
                    id: row12h
                    Layout.fillWidth: true
                    implicitHeight: 48
                    radius: 4

                    color: state12h.containsMouse
                        ? Colours.tPalette.m3surfaceContainerHighest
                        : Colours.tPalette.m3surfaceContainerHigh
                    Behavior on color { ColorAnimation { duration: 120 } }

                    StateLayer {
                        id: state12h
                        onClicked: Colours.use12Hour = !Colours.use12Hour
                    }

                    // Left Text Column
                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.right: switch12h.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 1

                        Text {
                            width: parent.width
                            text: "12-hour clock"
                            font.family: "Google Sans Flex"
                            font.pointSize: 11
                            font.weight: Font.Medium
                            color: Colours.palette.m3onSurface
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            text: "Use AM/PM format instead of 24h"
                            font.family: "Google Sans Flex"
                            font.pointSize: 8
                            color: Colours.palette.m3outline
                            elide: Text.ElideRight
                        }
                    }

                    // M3 Switch with Check/Cross Icon (Strictly Far Right)
                    Rectangle {
                        id: switch12h
                        anchors.right: parent.right
                        anchors.rightMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        implicitWidth: 42
                        implicitHeight: 24
                        radius: 12
                        color: Colours.use12Hour
                            ? Colours.palette.m3primary
                            : Colours.tPalette.m3surfaceContainerHighest
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Rectangle {
                            id: thumb12h
                            width: 18
                            height: 18
                            radius: 9
                            anchors.verticalCenter: parent.verticalCenter
                            x: Colours.use12Hour ? parent.width - width - 3 : 3
                            color: Colours.use12Hour ? Colours.palette.m3onPrimary : Colours.palette.m3outline
                            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                            MaterialIcon {
                                anchors.centerIn: parent
                                text: Colours.use12Hour ? "check" : "close"
                                fontStyle.pointSize: 11
                                color: Colours.use12Hour
                                    ? Colours.palette.m3primary
                                    : Colours.palette.m3surfaceContainerHigh
                            }
                        }
                    }
                }

                // ── Row 3: Light Mode (Middle in Group) ────────────
                Rectangle {
                    id: rowTheme
                    Layout.fillWidth: true
                    implicitHeight: 48
                    radius: 4

                    color: stateTheme.containsMouse
                        ? Colours.tPalette.m3surfaceContainerHighest
                        : Colours.tPalette.m3surfaceContainerHigh
                    Behavior on color { ColorAnimation { duration: 120 } }

                    StateLayer {
                        id: stateTheme
                        onClicked: {
                            const newMode = Colours.light ? "dark" : "light";
                            Colours.setMode(newMode);
                        }
                    }

                    // Left Text Column
                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.right: switchTheme.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 1

                        Text {
                            width: parent.width
                            text: "Light theme"
                            font.family: "Google Sans Flex"
                            font.pointSize: 11
                            font.weight: Font.Medium
                            color: Colours.palette.m3onSurface
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            text: "Use light color palette for greeter"
                            font.family: "Google Sans Flex"
                            font.pointSize: 8
                            color: Colours.palette.m3outline
                            elide: Text.ElideRight
                        }
                    }

                    // M3 Switch with Check/Cross Icon (Strictly Far Right)
                    Rectangle {
                        id: switchTheme
                        anchors.right: parent.right
                        anchors.rightMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        implicitWidth: 42
                        implicitHeight: 24
                        radius: 12
                        color: Colours.light
                            ? Colours.palette.m3primary
                            : Colours.tPalette.m3surfaceContainerHighest
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Rectangle {
                            id: thumbTheme
                            width: 18
                            height: 18
                            radius: 9
                            anchors.verticalCenter: parent.verticalCenter
                            x: Colours.light ? parent.width - width - 3 : 3
                            color: Colours.light ? Colours.palette.m3onPrimary : Colours.palette.m3outline
                            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                            MaterialIcon {
                                anchors.centerIn: parent
                                text: Colours.light ? "check" : "close"
                                fontStyle.pointSize: 11
                                color: Colours.light
                                    ? Colours.palette.m3primary
                                    : Colours.palette.m3surfaceContainerHigh
                            }
                        }
                    }
                }

                // ── Row 4: Lava Lamp Animation (Middle in Appearance Group) ────
                Rectangle {
                    id: rowAnim
                    Layout.fillWidth: true
                    implicitHeight: 48
                    radius: 4
                    topLeftRadius: 4
                    topRightRadius: 4
                    bottomLeftRadius: 4
                    bottomRightRadius: 4

                    color: stateAnim.containsMouse
                        ? Colours.tPalette.m3surfaceContainerHighest
                        : Colours.tPalette.m3surfaceContainerHigh
                    Behavior on color { ColorAnimation { duration: 120 } }

                    StateLayer {
                        id: stateAnim
                        onClicked: Colours.lavaLampEnabled = !Colours.lavaLampEnabled
                    }

                    // Left Text Column
                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.right: switchAnim.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 1

                        Text {
                            width: parent.width
                            text: "Lava lamp animation"
                            font.family: "Google Sans Flex"
                            font.pointSize: 11
                            font.weight: Font.Medium
                            color: Colours.palette.m3onSurface
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            text: "Dynamic fluid background shapes"
                            font.family: "Google Sans Flex"
                            font.pointSize: 8
                            color: Colours.palette.m3outline
                            elide: Text.ElideRight
                        }
                    }

                    // M3 Switch with Check/Cross Icon (Strictly Far Right)
                    Rectangle {
                        id: switchAnim
                        anchors.right: parent.right
                        anchors.rightMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        implicitWidth: 42
                        implicitHeight: 24
                        radius: 12
                        color: Colours.lavaLampEnabled
                            ? Colours.palette.m3primary
                            : Colours.tPalette.m3surfaceContainerHighest
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Rectangle {
                            id: thumbAnim
                            width: 18
                            height: 18
                            radius: 9
                            anchors.verticalCenter: parent.verticalCenter
                            x: Colours.lavaLampEnabled ? parent.width - width - 3 : 3
                            color: Colours.lavaLampEnabled ? Colours.palette.m3onPrimary : Colours.palette.m3outline
                            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                            MaterialIcon {
                                anchors.centerIn: parent
                                text: Colours.lavaLampEnabled ? "check" : "close"
                                fontStyle.pointSize: 11
                                color: Colours.lavaLampEnabled
                                    ? Colours.palette.m3primary
                                    : Colours.palette.m3surfaceContainerHigh
                            }
                        }
                    }
                }

                Rectangle {
                    id: rowAnim2
                    Layout.fillWidth: true
                    implicitHeight: 48
                    radius: 4
                    topLeftRadius: 4
                    topRightRadius: 4
                    bottomLeftRadius: 4
                    bottomRightRadius: 4

                    color: stateAnim2.containsMouse
                        ? Colours.tPalette.m3surfaceContainerHighest
                        : Colours.tPalette.m3surfaceContainerHigh
                    Behavior on color { ColorAnimation { duration: 120 } }

                    StateLayer {
                        id: stateAnim2
                        onClicked: Colours.wallpaperEnabled = !Colours.wallpaperEnabled
                    }

                    // Left Text Column
                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.right: switchAnim2.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 1

                        Text {
                            width: parent.width
                            text: "Dynamic Wallpaper"
                            font.family: "Google Sans Flex"
                            font.pointSize: 11
                            font.weight: Font.Medium
                            color: Colours.palette.m3onSurface
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            text: "Show synced wallpaper from caelestia"
                            font.family: "Google Sans Flex"
                            font.pointSize: 8
                            color: Colours.palette.m3outline
                            elide: Text.ElideRight
                        }
                    }

                    // M3 Switch with Check/Cross Icon (Strictly Far Right)
                    Rectangle {
                        id: switchAnim2
                        anchors.right: parent.right
                        anchors.rightMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        implicitWidth: 42
                        implicitHeight: 24
                        radius: 12
                        color: Colours.wallpaperEnabled
                            ? Colours.palette.m3primary
                            : Colours.tPalette.m3surfaceContainerHighest
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Rectangle {
                            id: thumbAnim2
                            width: 18
                            height: 18
                            radius: 9
                            anchors.verticalCenter: parent.verticalCenter
                            x: Colours.wallpaperEnabled ? parent.width - width - 3 : 3
                            color: Colours.wallpaperEnabled ? Colours.palette.m3onPrimary : Colours.palette.m3outline
                            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                            MaterialIcon {
                                anchors.centerIn: parent
                                text: Colours.wallpaperEnabled ? "check" : "close"
                                fontStyle.pointSize: 11
                                color: Colours.wallpaperEnabled
                                    ? Colours.palette.m3primary
                                    : Colours.palette.m3surfaceContainerHigh
                            }
                        }
                    }
                }

                // ── Row 5: Skip Clock Screen (Last in Appearance Group) ────
                Rectangle {
                    id: rowSkipClock
                    Layout.fillWidth: true
                    implicitHeight: 48
                    radius: 4
                    topLeftRadius: 4
                    topRightRadius: 4
                    bottomLeftRadius: 14
                    bottomRightRadius: 14

                    color: stateSkipClock.containsMouse
                        ? Colours.tPalette.m3surfaceContainerHighest
                        : Colours.tPalette.m3surfaceContainerHigh
                    Behavior on color { ColorAnimation { duration: 120 } }

                    StateLayer {
                        id: stateSkipClock
                        onClicked: Colours.skipClockPage = !Colours.skipClockPage
                    }

                    // Left Text Column
                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.right: switchSkipClock.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 1

                        Text {
                            width: parent.width
                            text: "Skip clock screen"
                            font.family: "Google Sans Flex"
                            font.pointSize: 11
                            font.weight: Font.Medium
                            color: Colours.palette.m3onSurface
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            text: "Open login card immediately on startup"
                            font.family: "Google Sans Flex"
                            font.pointSize: 8
                            color: Colours.palette.m3outline
                            elide: Text.ElideRight
                        }
                    }

                    // M3 Switch with Check/Cross Icon (Strictly Far Right)
                    Rectangle {
                        id: switchSkipClock
                        anchors.right: parent.right
                        anchors.rightMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        implicitWidth: 42
                        implicitHeight: 24
                        radius: 12
                        color: Colours.skipClockPage
                            ? Colours.palette.m3primary
                            : Colours.tPalette.m3surfaceContainerHighest
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Rectangle {
                            id: thumbSkipClock
                            width: 18
                            height: 18
                            radius: 9
                            anchors.verticalCenter: parent.verticalCenter
                            x: Colours.skipClockPage ? parent.width - width - 3 : 3
                            color: Colours.skipClockPage ? Colours.palette.m3onPrimary : Colours.palette.m3outline
                            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                            MaterialIcon {
                                anchors.centerIn: parent
                                text: Colours.skipClockPage ? "check" : "close"
                                fontStyle.pointSize: 11
                                color: Colours.skipClockPage
                                    ? Colours.palette.m3primary
                                    : Colours.palette.m3surfaceContainerHigh
                            }
                        }
                    }
                }

                // ── Section 2 Header: Session (Visible in test mode) ─
                Text {
                    visible: !Greetd.available
                    text: "Session"
                    font.family: "Google Sans Flex"
                    font.pointSize: 9
                    font.weight: Font.DemiBold
                    color: Colours.palette.m3onSurfaceVariant
                    Layout.leftMargin: 4
                    Layout.topMargin: 8
                    Layout.bottomMargin: 4
                }

                // ── Row 5: Exit Test Mode (Single Group) ───────────
                Rectangle {
                    visible: !Greetd.available
                    Layout.fillWidth: true
                    implicitHeight: 46
                    radius: 14
                    color: stateExit.containsMouse
                        ? Qt.alpha(Colours.palette.m3errorContainer, 0.70)
                        : Qt.alpha(Colours.palette.m3errorContainer, 0.40)
                    Behavior on color { ColorAnimation { duration: 120 } }

                    StateLayer {
                        id: stateExit
                        color: Colours.palette.m3onErrorContainer
                        onClicked: root.exitRequested()
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 10

                        MaterialIcon {
                            text: "logout"
                            fontStyle.pointSize: 16
                            color: Colours.palette.m3onErrorContainer
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                Layout.fillWidth: true
                                text: "Exit test mode"
                                font.family: "Google Sans Flex"
                                font.pointSize: 11
                                font.weight: Font.Medium
                                color: Colours.palette.m3onErrorContainer
                                horizontalAlignment: Text.AlignLeft
                            }

                            Text {
                                Layout.fillWidth: true
                                text: "Close greeter preview window"
                                font.family: "Google Sans Flex"
                                font.pointSize: 8
                                color: Qt.alpha(Colours.palette.m3onErrorContainer, 0.75)
                                horizontalAlignment: Text.AlignLeft
                            }
                        }

                        MaterialIcon {
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            text: "chevron_right"
                            fontStyle.pointSize: 16
                            color: Colours.palette.m3onErrorContainer
                        }
                    }
                }

                // ── Section 3 Header: Battery (Visible in test mode) ─
                Text {
                    visible: !Greetd.available
                    text: "Battery"
                    font.family: "Google Sans Flex"
                    font.pointSize: 9
                    font.weight: Font.DemiBold
                    color: Colours.palette.m3onSurfaceVariant
                    Layout.leftMargin: 4
                    Layout.topMargin: 8
                    Layout.bottomMargin: 4
                }

                // ── Row: Charging (First in Battery Group) ──────────
                Rectangle {
                    id: rowCharge
                    visible: !Greetd.available
                    Layout.fillWidth: true
                    implicitHeight: 48
                    topLeftRadius: 14
                    topRightRadius: 14
                    bottomLeftRadius: 4
                    bottomRightRadius: 4

                    color: stateCharge.containsMouse
                        ? Colours.tPalette.m3surfaceContainerHighest
                        : Colours.tPalette.m3surfaceContainerHigh
                    Behavior on color { ColorAnimation { duration: 120 } }

                    StateLayer {
                        id: stateCharge
                        onClicked: BatteryState.simCharging = !BatteryState.simCharging
                    }

                    // Left Text Column
                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.right: switchCharge.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 1

                        Text {
                            width: parent.width
                            text: "Charging"
                            font.family: "Google Sans Flex"
                            font.pointSize: 11
                            font.weight: Font.Medium
                            color: Colours.palette.m3onSurface
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            text: "Simulate plugged-in power"
                            font.family: "Google Sans Flex"
                            font.pointSize: 8
                            color: Colours.palette.m3outline
                            elide: Text.ElideRight
                        }
                    }

                    // M3 Switch with Check/Cross Icon (Strictly Far Right)
                    Rectangle {
                        id: switchCharge
                        anchors.right: parent.right
                        anchors.rightMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        implicitWidth: 42
                        implicitHeight: 24
                        radius: 12
                        color: BatteryState.simCharging
                            ? Colours.palette.m3primary
                            : Colours.tPalette.m3surfaceContainerHighest
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Rectangle {
                            id: thumbCharge
                            width: 18
                            height: 18
                            radius: 9
                            anchors.verticalCenter: parent.verticalCenter
                            x: BatteryState.simCharging ? parent.width - width - 3 : 3
                            color: BatteryState.simCharging ? Colours.palette.m3onPrimary : Colours.palette.m3outline
                            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                            MaterialIcon {
                                anchors.centerIn: parent
                                text: BatteryState.simCharging ? "check" : "close"
                                fontStyle.pointSize: 11
                                color: BatteryState.simCharging
                                    ? Colours.palette.m3primary
                                    : Colours.palette.m3surfaceContainerHigh
                            }
                        }
                    }
                }

                // ── Row: Battery Level Slider (Last in Battery Group) ──
                SliderRow {
                    visible: !Greetd.available
                    Layout.fillWidth: true
                    topLeftRadius: 4
                    topRightRadius: 4
                    bottomLeftRadius: 14
                    bottomRightRadius: 14

                    icon: "battery_full"
                    label: "Battery level"
                    value: BatteryState.simPercentage / 100
                    onMoved: v => BatteryState.simPercentage = v * 100
                }
            }
        }
    }

    // ── Trigger Button Rect (Bottom-Left, connects with Popup) ───
    BlobRect {
        id: btnRect

        anchors.fill: parent
        group: blobGroup
        radius: root.isOpen ? 22 : 16

        Behavior on radius { NumberAnimation { duration: 150 } }

        MaterialIcon {
            anchors.centerIn: parent
            text: root.isOpen ? "close" : "tune"
            fontStyle.pointSize: 18
            color: root.isOpen
                ? Colours.palette.m3primary
                : Colours.palette.m3onSurface
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: {
                root.isOpen = !root.isOpen;
                if (!root.isOpen) root.shapeMenuOpen = false;
            }
        }
    }
}