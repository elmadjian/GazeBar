import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12

ApplicationWindow {
    id: mainControl
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.WindowTransparentForInput
    width: 1920
    height: 1080
    //color: "green"
    color: "transparent"
    visible: true
    signal updatePosition(var x, var y)
    property bool ready: false


    Component.onCompleted: {
        toolbarManager.update_position.connect(updatePosition);
    }

    onUpdatePosition: {
        gaze.x = x;
        gaze.y = y;
        if (mainControl.ready) {
            for (var i=0; i < bar.children.length; i++) {
                if (bar.children[i].objectName == "button") {
                    bar.children[i].testCollision(x,y);
                }
            }
            if (bar.collision && (y + 150 < bar.y + bar.parent.y || y > bar.y + bar.parent.y + bar.height + 150)) {
                for (var i=0; i < bar.children.length; i++) {
                    if (bar.children[i].myId == bar.selectedButton) {
                        bar.children[i].defaultState = "selected";
                    }
                    if (bar.children[i].myId == bar.prevSelected) {
                        bar.children[i].defaultState = "unfocused";
                    }
                }
                bar.prevSelected = bar.selectedButton;
                bar.collision = false;
            }
        }
    }

    Rectangle {
        //FOR DEBUG ONLY!!!
        id: gaze
        x: -99
        y: -99
        width: 80
        height: 80
        radius: width*0.5
        color: "#4c16ff4b"
        z:1
    }

    Rectangle {
        id: appWindow
        width: 1000
        height: 150
        //color: "green"
        color: "transparent"
        visible: true
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 300

//        Transition {
//            PropertyAnimation {
//                properties: "visible"
//                easing: Easing.InOutQuad
//                duration: 200
//            }
//        }

        RowLayout {
            id: bar
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            spacing: 40
            property var selectedButton: 0
            property var prevSelected: 0
            property bool collision: false

            EyeButton {
                id: brush
                imageURL: "figs/painting_brush.svg"
                defaultState: "selected"
                myId: 0
            }
            EyeButton {
                id: bucket
                imageURL: "figs/painting_bucket.svg"
                myId: 1
            }
            EyeButton {
                id: crop
                imageURL: "figs/painting_crop.png"
                myId: 2
            }
            EyeButton {
                id: circle
                imageURL: "figs/painting_circle.svg"
                myId: 3
            }
            EyeButton {
                id: square
                imageURL: "figs/painting_square.svg"
                myId: 4
            }
            EyeButton {
                id: wand
                imageURL: "figs/painting_magic_wand.svg"
                myId: 5
            }
            EyeButton {
                id: move
                imageURL: "figs/painting_move.svg"
                myId: 6
            }

            Component.onCompleted: { mainControl.ready = true }

        }
    }
}
