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
    property var bars: [brushBarWindow, geometricBarWindow, selectionBarWindow]


    Component.onCompleted: {
        toolbarManager.update_position.connect(updatePosition);
    }

    onUpdatePosition: {
        gaze.x = x;
        gaze.y = y;

        testBarCollision(bar, x, y, "bottom");
        testBarCollision(brushBar, x, y, "right");
        testBarCollision(selectionBar, x, y, "right");
        testBarCollision(geometricBar, x, y, "right");
        if (bottomTrigger.testCollision(x,y) === "open") {
            bar.visible = true;
            bars[bar.barIdx[bar.selectedButton]].visible = true;
        } else {
            bar.visible = false;
            bars[bar.barIdx[bar.selectedButton]].visible = false;
        }

    }

    //make a secondary bar visible or not
    //-----------------------------------
    function updateSecBarVisibility(curr_idx) {
        for (var i=0; i < bars.length; i++) {
            if (i === curr_idx) {
                bars[i].visible = true;
            } else {
                bars[i].visible = false;
            }
        }
    }

    //update which object is selected in a bar
    //---------------------------------------
    function updateBarState(barId) {
        for (var i=0; i < barId.children.length; i++) {
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

    //check collisions with a bar if it is visible
    //--------------------------------------------
    function testBarCollision(barId, x, y, position) {
        if (barId.visible) {
            for (var i=0; i < barId.children.length; i++) {
                if (barId.children[i].objectName === "button") {
                    barId.children[i].testCollision(x,y);
                }
            }
            if (barId.selectedButton !== barId.prevSelected) {
                if (position === "bottom" && barId.collision) {
                    if (y + 150 < barId.y + barId.parent.y || y > barId.y + barId.parent.y + barId.height + 150) {
                        updateBarState(barId);
                        updateSecBarVisibility(barId.barIdx[barId.selectedButton]);
                    }
                }
                else if (position === "right" && barId.collision) {
                    if (x - 150 < barId.x + barId.parent.x || x > barId.x + barId.parent.x + barId.width + 150) {
                        updateBarState(barId);
                    }
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
        width: 1300
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
            property var barIdx: {
                "brush": 0,
                "geo": 1,
                "select":2
            }


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
                imageURL: "figs/painting_square.svg"
                myId: "geo"
            }
            EyeButton {
                id: square
                imageURL: "figs/selection_square.svg"
                myId: "select"
            }
            EyeButton {
                id: move
                imageURL: "figs/painting_move.svg"
                myId: "move"
            }
        }
    }

    SecondaryBar {
        id: brushBarWindow
        visible: false

        ColumnLayout {
            id: brushBar
            anchors.verticalCenter: parent.verticalCenter
            spacing: 25
            property var selectedButton: "brush1"
            property var prevSelected: "brush1"
            property bool collision: false

            EyeButton {
                imageURL: "figs/brush_1.png"
                myId: "brush1"
                fac: 0.8
            }
            EyeButton {
                imageURL: "figs/brush_2.png"
                myId: "brush2"
                fac: 0.8
            }
            EyeButton {
                imageURL: "figs/brush_3.png"
                myId: "brush3"
                fac: 0.8
            }
            EyeButton {
                imageURL: "figs/brush_4.png"
                myId: "brush4"
                fac: 0.8
            }
            EyeButton {
                imageURL: "figs/brush_5.png"
                myId: "brush5"
                fac: 0.8
            }
            EyeButton {
                imageURL: "figs/brush_6.png"
                myId: "brush6"
                fac: 0.8
            }
            EyeButton {
                imageURL: "figs/brush_7.png"
                myId: "brush7"
                fac: 0.8
            }
        }
    }


    SecondaryBar {
        id: selectionBarWindow
        visible: false

        ColumnLayout {
            id: selectionBar
            anchors.verticalCenter: parent.verticalCenter
            spacing: 25
            property var selectedButton: "selection1"
            property var prevSelected: "selection1"
            property bool collision: false

            EyeButton {
                imageURL: "figs/selection_square.svg"
                myId: "selection1"
            }
            EyeButton {
                imageURL: "figs/selection_circle.svg"
                myId: "selection2"
            }
            EyeButton {
                imageURL: "figs/selection_contour.svg"
                myId: "selection3"
            }
            EyeButton {
                imageURL: "figs/selection_magic_wand.svg"
                myId: "selection4"
            }
        }
    }


    SecondaryBar {
        id: geometricBarWindow
        visible: false

        ColumnLayout {
            id: geometricBar
            anchors.verticalCenter: parent.verticalCenter
            spacing: 25
            property var selectedButton: "geo1"
            property var prevSelected: "geo1"
            property bool collision: false

            EyeButton {
                imageURL: "figs/painting_square.svg"
                myId: "geo1"
            }
            EyeButton {
                imageURL: "figs/painting_circle.svg"
                myId: "geo2"
            }
            EyeButton {
                imageURL: "figs/path_bezier.svg"
                myId: "geo3"
            }
            EyeButton {
                imageURL: "figs/path_line.svg"
                myId: "geo4"
            }
            EyeButton {
                imageURL: "figs/path_polygon.svg"
                myId: "geo5"
            }
        }
    }
}
