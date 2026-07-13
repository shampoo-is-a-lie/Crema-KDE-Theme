/*
    Crema splash screen — espresso palette, coffee-cup mark.
    Adapted from the Breeze splash (SPDX-FileCopyrightText: 2014 Marco Martin).

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import org.kde.kirigami as Kirigami

Rectangle {
    id: root
    color: "#2C1E16"

    property int stage

    onStageChanged: {
        if (stage == 2) {
            introAnimation.running = true;
        } else if (stage == 5) {
            introAnimation.target = busyIndicator;
            introAnimation.from = 1;
            introAnimation.to = 0;
            introAnimation.running = true;
        }
    }

    Item {
        id: content
        anchors.fill: parent
        opacity: 0

        Image {
            id: logo
            readonly property real size: Kirigami.Units.gridUnit * 8
            anchors.centerIn: parent
            asynchronous: true
            source: "images/logo.svg"
            sourceSize.width: size
            sourceSize.height: size
        }

        Image {
            id: busyIndicator
            y: parent.height - (parent.height - logo.y) / 2 - height / 2
            anchors.horizontalCenter: parent.horizontalCenter
            asynchronous: true
            source: "images/busy.svg"
            sourceSize.height: Kirigami.Units.gridUnit * 2
            sourceSize.width: Kirigami.Units.gridUnit * 2
            RotationAnimator on rotation {
                from: 0
                to: 360
                duration: 2000
                loops: Animation.Infinite
                running: Kirigami.Units.longDuration > 1
            }
        }

        Text {
            anchors {
                bottom: parent.bottom
                right: parent.right
                margins: Kirigami.Units.gridUnit * 1.5
            }
            color: "#FFE6A7"
            text: "Crema"
            font.family: "Poppins"
            font.weight: Font.DemiBold
            font.pointSize: 14
            textFormat: Text.PlainText
            Accessible.name: text
            Accessible.role: Accessible.StaticText
        }
    }

    OpacityAnimator {
        id: introAnimation
        running: false
        target: content
        from: 0
        to: 1
        duration: Kirigami.Units.veryLongDuration * 2
        easing.type: Easing.InOutQuad
    }
}
