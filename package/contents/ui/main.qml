import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as P5Support

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.DefaultBackground | PlasmaCore.Types.ConfigurableBackground
    //Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    Plasmoid.icon: "battery"
    Plasmoid.title: info.ok && info.model ? info.model : i18n("UPS Monitor")

    implicitWidth: Kirigami.Units.gridUnit * 24
    implicitHeight: Kirigami.Units.gridUnit * 15
    Layout.minimumWidth: Kirigami.Units.gridUnit * 20
    Layout.minimumHeight: Kirigami.Units.gridUnit * 12

    readonly property string helperPath: String(Qt.resolvedUrl("../scripts/nut-status.sh")).replace(/^file:\/\//, "")
    readonly property int refreshSeconds: Math.max(3, Number(Plasmoid.configuration.refreshSeconds || 10))
    readonly property string upsName: String(Plasmoid.configuration.upsName || "ups")
    readonly property string sourceCommand: "/bin/sh -lc " + shellQuote(shellQuote(helperPath) + " " + shellQuote(upsName))
    readonly property real countdownProgress: {
        const totalMs = refreshSeconds * 1000
        if (totalMs <= 0) {
            return 0
        }
        return Math.max(0, Math.min(1, (refreshDeadlineMs - currentTimeMs) / totalMs))
    }
    readonly property int countdownSecondsRemaining: Math.max(0, Math.ceil((refreshDeadlineMs - currentTimeMs) / 1000))

    property string lastError: ""
    property double currentTimeMs: Date.now()
    property double refreshDeadlineMs: Date.now() + (refreshSeconds * 1000)
    property var info: ({
        ok: false,
        upsName: upsName,
        model: "",
        status: "",
        onBattery: false,
        batteryPercent: null,
        powerWatts: null,
        outputVoltage: null,
        runtimeSeconds: null,
        loadPercent: null,
        inputVoltage: null,
        inputFrequency: null,
        batteryVoltage: null,
        batteryVoltageNominal: null,
        temperature: null,
        alarm: "",
        lastPowerLoss: "",
        error: ""
    })

    property bool hasAlarm: info.ok && !!info.alarm && String(info.alarm).length > 0
    property bool isCharging: info.ok && hasStatusToken("CHRG")
    property bool showLastPowerLoss: Plasmoid.configuration.showLastPowerLoss

    // Icon sources for the UI
    readonly property string statusIconSource: {
        if (hasStatusToken("OL") && hasStatusToken("BOOST")) {
            return Qt.resolvedUrl("../resources/plug-circle-plus-solid-full.svg")
        }
        if (hasStatusToken("OL") && hasStatusToken("TRIM")) {
            return Qt.resolvedUrl("../resources/plug-circle-minus-solid-full.svg")
        }
        if (hasStatusToken("OB") && hasStatusToken("LB")) {
            return Qt.resolvedUrl("../resources/battery-empty-solid-full.svg")
        }
        if (hasStatusToken("OB")) {
            return Qt.resolvedUrl("../resources/battery-full-solid-full.svg")
        }
        if (hasStatusToken("OL")) {
            return Qt.resolvedUrl("../resources/plug-circle-check-solid-full.svg")
        }
        return hasAlarm ? "dialog-warning" : info.onBattery ? "battery" : "connector-plug"
    }

    readonly property string inputIconSource: Qt.resolvedUrl("../resources/plug-solid-full.svg")
    readonly property string outputIconSource: Qt.resolvedUrl("../resources/outlet.svg")
    readonly property string batteryIconSource: Qt.resolvedUrl("../resources/car-battery-solid-full.svg")
    readonly property string loadIconSource: Qt.resolvedUrl("../resources/gauge-solid-full.svg")
    readonly property string temperatureIconSource: Qt.resolvedUrl("../resources/temperature-high-solid-full.svg")
    readonly property string wavesineIconSource: Qt.resolvedUrl("../resources/wave-sine.svg")
    readonly property string clockIconSource: Qt.resolvedUrl("../resources/clock-rotate-left-solid-full.svg")
    readonly property string upsIconSource: Qt.resolvedUrl("../resources/bolt-solid-full.svg")

    property color statusColor: {
        if (!info.ok) {
            return Kirigami.Theme.neutralTextColor
        }
        if (hasAlarm) {
            return Kirigami.Theme.negativeTextColor
        }
        if (info.onBattery) {
            return Kirigami.Theme.neutralTextColor
        }
        return Kirigami.Theme.positiveTextColor
    }

    // Strings for the UI
    property string percentText: formatPercent(info.batteryPercent)
    property string powerText: formatNumber(info.powerWatts, "W", 0)
    property string voltageText: formatNumber(info.outputVoltage, "V", 0)
    property string runtimeTextValue: formatRuntime(info.runtimeSeconds)
    property string loadText: formatNumber(info.loadPercent, "%", 0)
    property string inputVoltageText: formatNumber(info.inputVoltage, "V", 0)
    property string inputFrequencyText: formatNumber(info.inputFrequency, "Hz", 2)
    property string batteryVoltageText: formatNumber(info.batteryVoltage, "V", 2)
    property string batteryVoltageNominalText: formatNumber(info.batteryVoltageNominal, "V", 2)
    property string temperatureText: formatNumber(info.temperature, "°C", 1)
    property string lastPowerLossText: info.ok && info.lastPowerLoss ? info.lastPowerLoss : i18n("Never")
    property string compactSecondaryText: {
        if (!info.ok) {
            return i18n("No data")
        }
        if (hasAlarm) {
            return info.alarm
        }
        return powerText
    }
    property string statusLine: {
        if (!info.ok) {
            return i18n("Unavailable")
        }
        if (hasAlarm) {
            if (info.onBattery) {
                return i18n("Alarm • On battery")
            }
            return isCharging ? i18n("Alarm • Charging") : i18n("Alarm")
        }
        if (info.onBattery) {
            return i18n("Running on battery")
        }
        if (isCharging) {
            return i18n("Online • Charging")
        }
        return i18n("Online")
    }

    toolTipMainText: Plasmoid.title
    toolTipSubText: {
        if (!info.ok) {
            return lastError
        }
        if (hasAlarm) {
            return i18nc("@info:tooltip", "%1, %2, last power loss: %3", statusLine, info.alarm, lastPowerLossText)
        }
        return i18nc("@info:tooltip", "Status: %1 | Input: %2 | Output: %3", info.status, inputVoltageText, voltageText)
    }

    switchWidth: -1
    switchHeight: -1
    compactRepresentation: CompactRepresentation { }
    fullRepresentation: FullRepresentation { }
    preferredRepresentation: Plasmoid.formFactor === PlasmaCore.Types.Planar ? fullRepresentation : compactRepresentation

    onRefreshSecondsChanged: refreshDeadlineMs = Date.now() + (refreshSeconds * 1000)

    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: root.currentTimeMs = Date.now()
    }

    function shellQuote(value) {
        return "'" + String(value).replace(/'/g, "'\"'\"'") + "'"
    }

    function commandLine() {
        return sourceCommand
    }

    function statusTokens() {
        return String(info.status || "").trim().split(/\s+/).filter(Boolean)
    }

    function hasStatusToken(token) {
        return statusTokens().indexOf(token) >= 0
    }

    function formatPercent(value) {
        if (value === null || value === undefined || value === "") {
            return i18n("N/A")
        }
        return i18nc("@item:intext battery percent", "%1%", Number(value).toFixed(0))
    }

    function formatNumber(value, unit, decimals) {
        if (value === null || value === undefined || value === "") {
            return i18n("N/A")
        }
        return Number(value).toFixed(decimals) + " " + unit
    }

    function formatRuntime(seconds) {
        const total = Number(seconds)
        if (!Number.isFinite(total) || total <= 0) {
            return i18n("N/A")
        }

        const hours = Math.floor(total / 3600)
        const minutes = Math.floor((total % 3600) / 60)

        if (hours > 0) {
            if (minutes > 0) {
                return i18nc("@item:intext runtime", "%1 h %2 min", hours, minutes)
            }
            return i18nc("@item:intext runtime", "%1 h", hours)
        }

        return i18nc("@item:intext runtime", "%1 min", Math.max(1, minutes))
    }

    function extractPayload(data) {
        const namedKeys = ["stdout", "output", "data", "text"]
        for (let i = 0; i < namedKeys.length; ++i) {
            const value = data[namedKeys[i]]
            if (typeof value === "string" && value.trim().length > 0) {
                return value
            }
        }

        for (const key in data) {
            const value = data[key]
            if (typeof value === "string" && value.trim().startsWith("{")) {
                return value
            }
        }

        return ""
    }

    P5Support.DataSource {
        id: execSource
        engine: "executable"
        interval: root.refreshSeconds * 1000
        connectedSources: [root.sourceCommand]

        onNewData: function(sourceName, data) {
            if (sourceName !== root.sourceCommand) {
                return
            }

            const payload = root.extractPayload(data)

            if (!payload.length) {
                root.lastError = i18n("No data returned by helper")
                root.info = {
                    ok: false,
                    upsName: root.upsName,
                    model: "",
                    status: "",
                    onBattery: false,
                    batteryPercent: null,
                    powerWatts: null,
                    outputVoltage: null,
                    runtimeSeconds: null,
                    loadPercent: null,
                    inputVoltage: null,
                    inputFrequency: null,
                    batteryVoltage: null,
                    batteryVoltageNominal: null,
                    temperature: null,
                    alarm: "",
                    lastPowerLoss: "",
                    error: root.lastError
                }
                root.refreshDeadlineMs = Date.now() + (root.refreshSeconds * 1000)
                return
            }

            try {
                const parsed = JSON.parse(payload)
                root.info = parsed
                root.lastError = parsed.ok ? "" : (parsed.error || i18n("Unknown UPS error"))
                root.refreshDeadlineMs = Date.now() + (root.refreshSeconds * 1000)
            } catch (error) {
                root.lastError = i18n("Invalid helper output")
                root.info = {
                    ok: false,
                    upsName: root.upsName,
                    model: "",
                    status: "",
                    onBattery: false,
                    batteryPercent: null,
                    powerWatts: null,
                    outputVoltage: null,
                    runtimeSeconds: null,
                    loadPercent: null,
                    inputVoltage: null,
                    inputFrequency: null,
                    batteryVoltage: null,
                    batteryVoltageNominal: null,
                    temperature: null,
                    alarm: "",
                    lastPowerLoss: "",
                    error: String(error)
                }
                root.refreshDeadlineMs = Date.now() + (root.refreshSeconds * 1000)
            }
        }
    }

    Connections {
        target: Plasmoid
        function onConfigurationChanged() {
            execSource.connectedSources = [root.sourceCommand]
        }
    }
}
