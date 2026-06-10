import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as P5Support

PlasmoidItem {
    id: root

    property bool   present: false
    property bool   available: false
    property int    batteryLevel: 0
    property bool   charging: false
    property string deviceName: "Headset Control"
    property string featuresJson: "[]"
    property int    chatmix: 64
    property int    sidetone: 16

    preferredRepresentation: compactRepresentation
    compactRepresentation: CompactRepresentation {}
    fullRepresentation: FullRepresentation {}

    Plasmoid.title: root.deviceName

    P5Support.DataSource {
        id: pollSource
        engine: "executable"
        connectedSources: []
        onNewData: function(sourceName, data) {
            disconnectSource(sourceName);
            var code   = data["exit code"];
            var stdout = data["stdout"].trim();
            if (code !== 0 || stdout === "") {
                root.present   = false;
                root.available = false;
                pollTimer.restart();
                return;
            }
            try {
                var result = JSON.parse(stdout);
                if (!result.devices || result.devices.length === 0
                        || result.devices[0].status !== "success") {
                    root.present   = false;
                    root.available = false;
                    pollTimer.restart();
                    return;
                }
                var dev = result.devices[0];
                root.present      = true;
                root.deviceName   = dev.device;
                root.featuresJson = JSON.stringify(dev.capabilities || []);

                if (dev.chatmix !== undefined && dev.chatmix !== null)
                    root.chatmix = dev.chatmix;

                var bat = dev.battery;
                if (!bat || bat.status === "BATTERY_UNAVAILABLE") {
                    root.available    = false;
                    root.batteryLevel = 0;
                    root.charging     = false;
                } else if (bat.status === "BATTERY_CHARGING") {
                    root.available    = true;
                    root.charging     = true;
                    root.batteryLevel = bat.level || 0;
                } else {
                    root.available    = true;
                    root.charging     = false;
                    root.batteryLevel = bat.level;
                }
            } catch (e) {
                root.present   = false;
                root.available = false;
            }
            pollTimer.restart();
        }
    }

    P5Support.DataSource {
        id: cmdSource
        engine: "executable"
        connectedSources: []
        onNewData: function(sourceName, data) {
            disconnectSource(sourceName);
        }
    }

    function runCommand(cmd) {
        cmdSource.connectSource(cmd);
    }

    Timer {
        id: pollTimer
        interval: plasmoid.configuration.pollingRate
        running: false
        repeat: false
        onTriggered: poll()
    }

    function poll() {
        pollSource.connectSource("/usr/local/bin/headsetcontrol -b -o json");
    }

    Component.onCompleted: poll()
}
