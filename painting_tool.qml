import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12

ApplicationWindow {
    id: mainControl
    flags: Qt.FramelessWindowHint | Qt.WindowTransparentForInput | Qt.WindowStaysOnTopHint
    width: 1920
    height: 1080
    //color: "green"
    color: "transparent"
    visible: true
    signal updatePosition(var x, var y)
    //property bool ready: false


    Component.onCompleted: {
        toolbarManager.update_position.connect(updatePosition);
    }

    onUpdatePosition: {
        gaze.x = x;
        gaze.y = y;

        testBarCollision(bar, x, y);
        testBarCollision(brushBar, x, y);
        if (bottomTrigger.testCollision(x,y) === "open") {
            bar.state = "available";
        } else {
            bar.state = "hidden";
        }

    }

    function testBarCollision(barId, x, y) {
        if (barId.visible) {
            for (var i=0; i < barId.children.length; i++) {
                if (barId.children[i].objectName === "button") {
                    barId.children[i].testCollision(x,y);
                }
            }
            if (barId.selectedButton !== barId.prevSelected) {
                if (barId.collision && (y + 150 < barId.y + barId.parent.y || y > barId.y + barId.parent.y + barId.height + 150)) {
                    for (i=0; i < barId.children.length; i++) {
                        if (barId.children[i].myId === barId.selectedButton) {
                            barId.children[i].defaultState = "selected";
                        }
                        if (barId.children[i].myId === barId.prevSelected) {
                            barId.children[i].defaultState = "unfocused";
                        }
                    }
                    barId.prevSelected = barId.selectedButton;
                    barId.collision = false;
                    toolbarManager.update_tool(String(barId.selectedButton));
                }
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
        property var iconSize: appWindow.height

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
        }
    }

    Rectangle {
        id: secondaryBarWindow
        width: 120
        height: 800
        //color: "green"
        color: "transparent"
        visible: true
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenterOffset: 830
        property var iconSize: secondaryBarWindow.width

        ColumnLayout {
            id: brushBar
            //anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            spacing: 25
            property var selectedButton: "brush"
            property var prevSelected: "brush"
            property bool collision: false

            EyeButton {
                id: brush1
                imageURL: "figs/painting_brush.svg"
                defaultState: "selected"
                myId: "brush"
            }
            EyeButton {
                id: brush2
                imageURL: "figs/painting_bucket.svg"
                myId: "bucket"
            }
            EyeButton {
                id: brush3
                imageURL: "figs/painting_eraser.svg"
                myId: "eraser"
            }
            EyeButton {
                id: brush4
                imageURL: "figs/painting_crop.png"
                myId: "crop"
            }
            EyeButton {
                id: brush5
                imageURL: "figs/painting_circle.svg"
                myId: "circle"
            }
            EyeButton {
                id: brush6
                imageURL: "figs/painting_square.svg"
                myId: "square"
            }
            EyeButton {
                id: brush7
                imageURL: "figs/painting_move.svg"
                myId: "move"
            }
        }
    }
}
