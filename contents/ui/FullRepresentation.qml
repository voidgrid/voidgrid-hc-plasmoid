import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: fullRoot
    spacing: Kirigami.Units.largeSpacing

    Layout.preferredWidth: Kirigami.Units.gridUnit * 20
    Layout.maximumWidth: Kirigami.Units.gridUnit * 20
    Layout.minimumHeight: implicitHeight
    Layout.maximumHeight: implicitHeight

    // ── Header ───────────────────────────────────────────────────────────────
    PlasmaExtras.Heading {
        Layout.fillWidth: true
        level: 3
        text: root.deviceName
    }

    // ── Battery ──────────────────────────────────────────────────────────────
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                source: root.charging        ? "battery-charging"   :
                        root.batteryLevel >= 80 ? "battery-100"     :
                        root.batteryLevel >= 60 ? "battery-080"     :
                        root.batteryLevel >= 40 ? "battery-060"     :
                        root.batteryLevel >= 20 ? "battery-040"     : "battery-020"
                width:  Kirigami.Units.iconSizes.small
                height: Kirigami.Units.iconSizes.small
            }

            PlasmaComponents.Label {
                font.bold: true
                text: "Battery"
                Layout.fillWidth: true
            }

            PlasmaComponents.Label {
                text: !root.available ? "Off" :
                      root.charging   ? "Charging" + (root.batteryLevel > 0 ? " – " + root.batteryLevel + "%" : "") :
                                        root.batteryLevel + "%"
                color: !root.available         ? Kirigami.Theme.disabledTextColor  :
                       root.charging           ? Kirigami.Theme.positiveTextColor  :
                       root.batteryLevel >= 50 ? Kirigami.Theme.positiveTextColor  :
                       root.batteryLevel >= 20 ? Kirigami.Theme.neutralTextColor   :
                                                 Kirigami.Theme.negativeTextColor
            }
        }

        PlasmaComponents.ProgressBar {
            Layout.fillWidth: true
            from: 0; to: 100
            value: root.batteryLevel
            visible: root.available
        }
    }

    // ── Sidetone ─────────────────────────────────────────────────────────────
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing
        visible: root.featuresJson.includes("CAP_SIDETONE")

        RowLayout {
            Layout.fillWidth: true
            PlasmaComponents.Label { font.bold: true; text: "Sidetone"; Layout.fillWidth: true }
            PlasmaComponents.Label { text: sidetoneSlider.value.toFixed(0) }
        }

        PlasmaComponents.Slider {
            id: sidetoneSlider
            Layout.fillWidth: true
            from: 0; to: 128; stepSize: 1
            value: root.sidetone
            live: false
            onMoved: {
                root.sidetone = Math.round(value);
                root.runCommand("/usr/local/bin/headsetcontrol -s " + Math.round(value));
            }
        }
    }

    Kirigami.Separator {
        Layout.fillWidth: true
        visible: root.featuresJson.includes("CAP_SIDETONE")
                 && root.featuresJson.includes("CAP_CHATMIX_STATUS")
    }

    // ── ChatMix ──────────────────────────────────────────────────────────────
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing
        visible: root.featuresJson.includes("CAP_CHATMIX_STATUS")

        RowLayout {
            Layout.fillWidth: true
            PlasmaComponents.Label { font.bold: true; text: "ChatMix"; Layout.fillWidth: true }
            PlasmaComponents.Label {
                font.italic: true
                text: root.chatmix === 64 ? "Balanced"
                    : root.chatmix <  64  ? "Game +" + (64 - root.chatmix)
                    :                       "Chat +" + (root.chatmix - 64)
            }
        }

        // Bidirectional balance bar — center = balanced
        Item {
            Layout.fillWidth: true
            height: Kirigami.Units.gridUnit * 0.6

            // Track background
            Rectangle {
                anchors.fill: parent
                color: Kirigami.Theme.alternateBackgroundColor
                radius: 3
            }

            // Game fill (leftward from centre)
            Rectangle {
                anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                width: root.chatmix < 64
                    ? (parent.width / 2) * ((64 - root.chatmix) / 64)
                    : 0
                color: Kirigami.Theme.neutralTextColor
                opacity: 0.8
                radius: 3
            }

            // Chat fill (rightward from centre)
            Rectangle {
                anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                width: root.chatmix > 64
                    ? (parent.width / 2) * ((root.chatmix - 64) / 64)
                    : 0
                color: Kirigami.Theme.highlightColor
                opacity: 0.8
                radius: 3
            }

            // Centre marker
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top; anchors.bottom: parent.bottom
                width: 2
                color: Kirigami.Theme.textColor
                opacity: 0.4
            }
        }

        RowLayout {
            Layout.fillWidth: true
            PlasmaComponents.Label { text: "◄ Game"; font.pixelSize: Kirigami.Units.gridUnit * 0.65; opacity: 0.7 }
            Item { Layout.fillWidth: true }
            PlasmaComponents.Label { text: "Chat ►"; font.pixelSize: Kirigami.Units.gridUnit * 0.65; opacity: 0.7 }
        }
    }

    Kirigami.Separator {
        Layout.fillWidth: true
        visible: root.featuresJson.includes("CAP_EQUALIZER_PRESET")
    }

    // ── EQ Presets ───────────────────────────────────────────────────────────
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing
        visible: root.featuresJson.includes("CAP_EQUALIZER_PRESET")

        PlasmaComponents.Label { font.bold: true; text: "EQ Preset" }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: Kirigami.Units.smallSpacing
            rowSpacing: Kirigami.Units.smallSpacing

            Repeater {
                model: [
                    { label: "Flat",       index: 0 },
                    { label: "Bass Boost", index: 1 },
                    { label: "Smiley",     index: 2 },
                    { label: "Focus",      index: 3 },
                ]
                PlasmaComponents.Button {
                    Layout.fillWidth: true
                    text: modelData.label
                    onClicked: root.runCommand("/usr/local/bin/headsetcontrol --eq-preset " + modelData.index)
                }
            }
        }
    }
}
