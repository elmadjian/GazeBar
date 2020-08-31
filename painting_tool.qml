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
            if (bar.visible) {
                for (var i=0; i < bar.children.length; i++) {
                    if (bar.children[i].objectName === "button") {
                        bar.children[i].testCollision(x,y);
                    }
                }
                if (bar.selectedButton !== bar.prevSelected) {
                    if (bar.collision && (y + 150 < bar.y + bar.parent.y || y > bar.y + bar.parent.y + bar.height + 150)) {
                        for (i=0; i < bar.children.length; i++) {
                            if (bar.children[i].myId === bar.selectedButton) {
                                bar.children[i].defaultState = "selected";
                            }
                            if (bar.children[i].myId === bar.prevSelected) {
                                bar.children[i].defaultState = "unfocused";
                            }
                        }
                        bar.prevSelected = bar.selectedButton;
                        bar.collision = false;
                        toolbarManager.update_tool(String(bar.selectedButton));
                    }
                }
            }
            if (bottomTrigger.testCollision(x,y) === "open") {
                bar.state = "available";
            } else {
                bar.state = "hidden";
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
        width: 1500
        height: 150
        //color: "green"
        color: "transparent"
        visible: true
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 420

        Trigger {
            id: bottomTrigger
            myId: "bottomTrigger"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 50
        }


        RowLayout {
            id: bar
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            spacing: 40
            property var selectedButton: "brush"
            property var prevSelected: "brush"
            property bool collision: false


            EyeButton {
                id: brush
                imageURL: "figs/painting_brush.svg"
                defaultState: "selected"
                myId: "brush"
            }
            EyeButton {
                id: bucket
                imageURL: "figs/painting_bucket.svg"
                myId: "bucket"
            }
            EyeButton {
                id: eraser
                imageURL: "figs/painting_eraser.svg"
                myId: "eraser"
            }
            EyeButton {
                id: crop
                imageURL: "figs/painting_crop.png"
                myId: "crop"
            }
            EyeButton {
                id: circle
                imageURL: "figs/painting_circle.svg"
                myId: "circle"
            }
            EyeButton {
                id: square
                imageURL: "figs/painting_square.svg"
                myId: "square"
            }
            EyeButton {
                id: move
                imageURL: "figs/painting_move.svg"
                myId: "move"
            }

            Component.onCompleted: { mainControl.ready = true }

            states: [
                State {
                    name: "hidden"
                    PropertyChanges {
                        target: bar
                        visible: false
                    }
                },
                State {
                    name: "available"
                    PropertyChanges {
                        target: bar
                        visible: true
                    }
                }
            ]

            transitions: [
                Transition {
                    PropertyAnimation {
                        properties: "y"
                        easing.type: Easing.Linear
                        duration: 100
                    }
                }
            ]

        }
    }

//    Rectangle {
//        id: secondaryBarWindow
//        width: 150
//        height: 1000
//        //color: "green"
//        color: "transparent"
//        visible: true
//        anchors.horizontalCenter: parent.horizontalCenter
//        anchors.verticalCenter: parent.verticalCenter
//        anchors.horizontalCenterOffset: 600

//        ColumnLayout {
//            id: bar2
//            anchors.horizontalCenter: parent.horizontalCenter
//            anchors.verticalCenter: parent.verticalCenter
//            spacing: 40
//            property var selectedButton: "brush"
//            property var prevSelected: "brush"
//            property bool collision: false
//        }
//    }
}
