pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Item {
    id: fullRoot

    anchors.fill: parent
    implicitWidth: Kirigami.Units.gridUnit * 24
    implicitHeight: Kirigami.Units.gridUnit * 15
    Layout.minimumWidth: Kirigami.Units.gridUnit * 20
    Layout.minimumHeight: Kirigami.Units.gridUnit * 12

    readonly property bool compactHeightMode: height < Kirigami.Units.gridUnit * 12
    readonly property real batteryPercentValue: Number(root.info.batteryPercent)
    readonly property real clampedBatteryPercent: Number.isFinite(batteryPercentValue) ? Math.max(0, Math.min(100, batteryPercentValue)) : 0
    readonly property real loadPercentValue: Number(root.info.loadPercent)
    readonly property real clampedLoadPercent: Number.isFinite(loadPercentValue) ? Math.max(0, Math.min(100, loadPercentValue)) : 0
    readonly property real cardHeight: compactHeightMode ? Kirigami.Units.gridUnit * 4.5 : Kirigami.Units.gridUnit * 5.5
    readonly property color secondaryTextColor: "#b9c5cc"
    readonly property color cardColor: "#263640"

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Kirigami.Theme.backgroundColor
        border.width: 1
        border.color: "#40515b"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: fullRoot.compactHeightMode ? Kirigami.Units.smallSpacing : Kirigami.Units.largeSpacing

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 4
                spacing: Kirigami.Units.largeSpacing

                Rectangle {
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 3.5
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 2.5
                    radius: 10
                    color: Kirigami.Theme.alternateBackgroundColor
                    //border.width: 2
                    //border.color: "#e7edf1"

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        source: root.upsIconSource
                        width: Kirigami.Units.iconSizes.large
                        height: width
                        opacity: root.info.onBattery ? 0.8 : 1
                        isMask: true
                        color: Kirigami.Theme.textColor

                        SequentialAnimation on opacity {
                            running: root.info.onBattery
                            loops: Animation.Infinite
                            OpacityAnimator { from: 1; to: 0.45; duration: 700 }
                            OpacityAnimator { from: 0.45; to: 1; duration: 700 }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    QQC2.Label {
                        Layout.fillWidth: true
                        text: root.info.ok && root.info.model ? root.info.model : i18n("UPS Monitor")
                        color: Kirigami.Theme.textColor
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize + 5
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    QQC2.Label {
                        Layout.fillWidth: true
                        text: root.info.ok ? root.info.upsName : root.lastError
                        color: Kirigami.Theme.disabledTextColor
                        elide: Text.ElideRight
                    }
                }

                Rectangle {
                    Layout.minimumWidth: Kirigami.Units.gridUnit * 8
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 9
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 3.5
                    radius: 10
                    color: root.hasAlarm ? Kirigami.Theme.negativeBackgroundColor : root.info.onBattery ? Kirigami.Theme.neutralBackgroundColor : Kirigami.Theme.positiveBackgroundColor
                    //border.width: 1
                    //border.color: root.hasAlarm ? "#9b514d" : root.info.onBattery ? "#98712d" : "#27825d"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Kirigami.Units.smallSpacing
                        spacing: Kirigami.Units.smallSpacing

                        Kirigami.Icon {
                            source: root.statusIconSource
                            isMask: true
                            color: root.hasAlarm ? Kirigami.Theme.negativeTextColor : root.info.onBattery ? Kirigami.Theme.neutralTextColor : Kirigami.Theme.positiveTextColor
                            Layout.preferredWidth: Kirigami.Units.iconSizes.large
                            Layout.preferredHeight: Kirigami.Units.iconSizes.large
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            QQC2.Label {
                                Layout.fillWidth: true
                                text: root.info.ok ? root.statusLine : i18n("Unavailable")
                                color: Kirigami.Theme.textColor
                                font.pointSize: Kirigami.Theme.defaultFont.pointSize + 2
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            QQC2.Label {
                                Layout.fillWidth: true
                                text: root.info.ok ? root.info.status : i18n("Check connection")
                                color: Kirigami.Theme.disabledTextColor
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }

            Rectangle {
                visible: root.hasAlarm
                Layout.fillWidth: true
                implicitHeight: Kirigami.Units.gridUnit * 3
                radius: 10
                color: Kirigami.Theme.negativeBackgroundColor
                //border.width: 1
                //border.color: "#9b514d"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.smallSpacing
                    spacing: 0

                    QQC2.Label {
                        Layout.fillWidth: true
                        text: i18n("Alarm")
                        color: Kirigami.Theme.negativeTextColor
                        font.bold: true
                    }

                    QQC2.Label {
                        Layout.fillWidth: true
                        text: root.info.alarm
                        color: Kirigami.Theme.textColor
                        wrapMode: Text.WordWrap
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: fullRoot.compactHeightMode ? Kirigami.Units.smallSpacing : Kirigami.Units.largeSpacing
                rowSpacing: fullRoot.compactHeightMode ? Kirigami.Units.smallSpacing : Kirigami.Units.largeSpacing

                Repeater {
                    model: [
                        { title: i18n("Input (AC)"), value: root.inputVoltageText, detail: root.inputFrequencyText, iconSource: root.inputIconSource, badge: "", progress: -1 },
                        { title: i18n("Output (AC)"), value: root.voltageText, detail: root.info.status || i18n("UPS output"), iconSource: root.outputIconSource, badge: "", progress: -1 },
                        { title: i18n("UPS Load"), value: root.loadText, iconSource: root.loadIconSource, badge: "", progress: root.info.loadPercent === null || root.info.loadPercent === undefined ? -1 : fullRoot.clampedLoadPercent },
                        { title: i18n("Battery"), value: root.batteryVoltageText, detail: i18n("Nominal: %1", root.batteryVoltageNominalText), iconSource: root.batteryIconSource, accent: Kirigami.Theme.positiveTextColor, badge: root.percentText, progress: -1 },
                        { title: i18n("Temperature"), value: root.temperatureText, iconSource: root.temperatureIconSource, badge: "", progress: -1 },
                        { title: i18n("Frequency"), value: root.inputFrequencyText, detail: i18n("Input frequency"), iconSource: root.wavesineIconSource, badge: "", progress: -1 }
                    ]

                    delegate: Rectangle {
                        id: metricCard
                        required property var modelData

                        Layout.fillWidth: true
                        implicitHeight: fullRoot.cardHeight
                        radius: 12
                        color: Kirigami.Theme.alternateBackgroundColor
                        border.width: 1
                        border.color: "#43545e"
                        clip: true

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Kirigami.Units.largeSpacing
                            spacing: Kirigami.Units.largeSpacing

                            Kirigami.Icon {
                                source: metricCard.modelData.iconSource
                                isMask: true
                                color: metricCard.modelData.accent || Kirigami.Theme.textColor
                                Layout.preferredWidth: Kirigami.Units.iconSizes.large
                                Layout.preferredHeight: Kirigami.Units.iconSizes.large

                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 1

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Kirigami.Units.smallSpacing

                                    QQC2.Label {
                                        Layout.fillWidth: true
                                        text: metricCard.modelData.title
                                        color: Kirigami.Theme.textColor
                                        elide: Text.ElideRight
                                    }

                                    QQC2.Label {
                                        visible: metricCard.modelData.badge.length > 0
                                        text: metricCard.modelData.badge
                                        color: Kirigami.Theme.positiveTextColor
                                        font.bold: true
                                    }
                                }

                                QQC2.Label {
                                    Layout.fillWidth: true
                                    text: metricCard.modelData.value
                                    color: Kirigami.Theme.textColor
                                    font.pointSize: Math.max(Kirigami.Theme.defaultFont.pointSize + 8, 20)
                                    font.bold: true
                                    elide: Text.ElideRight
                                }



                                Rectangle {
                                    visible: metricCard.modelData.progress >= 0
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 8
                                    radius: height / 2
                                    color: "#455761"

                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        width: parent.width * Math.max(0, Math.min(1, metricCard.modelData.progress / 100))
                                        radius: parent.radius
                                        color: "#35bdf0"
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                visible: root.showLastPowerLoss
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 4
                radius: 10
                color: Kirigami.Theme.alternateBackgroundColor
                border.width: 1
                border.color: "#43545e"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.largeSpacing
                    spacing: Kirigami.Units.largeSpacing

                    Kirigami.Icon {
                        source: root.clockIconSource
                        isMask: true
                        color: Kirigami.Theme.textColor
                        Layout.preferredWidth: Kirigami.Units.iconSizes.large
                        Layout.preferredHeight: Kirigami.Units.iconSizes.large
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        QQC2.Label {
                            Layout.fillWidth: true
                            text: i18n("Last power loss")
                            color: Kirigami.Theme.textColor
                            elide: Text.ElideRight
                        }

                        QQC2.Label {
                            Layout.fillWidth: true
                            text: root.lastPowerLossText
                            color: Kirigami.Theme.textColor
                            font.pointSize: Kirigami.Theme.defaultFont.pointSize + 2
                            font.bold: true
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }
}
