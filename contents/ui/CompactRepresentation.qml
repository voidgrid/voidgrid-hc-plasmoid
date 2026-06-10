import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

Item {
    id: compactRoot

    Layout.minimumWidth: Kirigami.Units.iconSizes.small + Kirigami.Units.smallSpacing + batteryLabel.implicitWidth
    Layout.preferredWidth: Layout.minimumWidth

    RowLayout {
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            source: "audio-headset"
            Layout.fillHeight: true
            Layout.preferredWidth: height
            opacity: root.available ? 1.0 : 0.4
        }

        PlasmaComponents.Label {
            id: batteryLabel
            text: {
                if (!root.present)   return "–";
                if (!root.available) return "off";
                if (root.charging)   return "⚡";
                return root.batteryLevel + "%";
            }
            color: {
                if (!root.available)         return Kirigami.Theme.disabledTextColor;
                if (root.charging)           return Kirigami.Theme.positiveTextColor;
                if (root.batteryLevel >= 50) return Kirigami.Theme.positiveTextColor;
                if (root.batteryLevel >= 20) return Kirigami.Theme.neutralTextColor;
                return Kirigami.Theme.negativeTextColor;
            }
            font.pixelSize: Kirigami.Units.gridUnit * 0.75
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.expanded = !root.expanded
    }
}
