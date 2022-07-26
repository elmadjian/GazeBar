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
    color: "transparent"
    visible: true
    signal updatePosition(var x, var y)
    signal updateSelection()
    property var bars: [brushBarWindow, geometricBarWindow, selectionBarWindow]
    property var secBar: false
    property var clearBar: true
    property bool updateFeedback: false
    property var mx: 0
    property var my: 0
    property bool changed: false


    Component.onCompleted: {
        toolbarManager.update_position.connect(updatePosition);
        toolbarManager.update_selection.connect(updateSelection);
    }

    onUpdatePosition: {
        if (toolbarManager.debug) {
            gaze.x = x;
            gaze.y = y;
        }
        testBarCollision(bar, x, y, "bottom", false);
        testBarCollision(brushBar, x, y, "right", false);
        testBarCollision(selectionBar, x, y, "right", false);
        testBarCollision(geometricBar, x, y, "right", false);
        bottomTrigger.testCollision(x, y);
        //checkUpdateFeedback(x, y);
        mx = x;
        my = y;
    }

    onUpdateSelection: {
        testBarCollision(bar, mx, my, "bottom", true);
        testBarCollision(brushBar, mx, my, "right", true);
        testBarCollision(selectionBar, mx, my, "right", true);
        testBarCollision(geometricBar, mx, my, "right", true);
        if (bottomTrigger.focused) {
            checkBarVisibility();
        }

    }

    //run the trigger check to show or hide bars
    //------------------------------------------
    function checkBarVisibility() {
        bottomTrigger.changeDefaultSate();
        if (bottomTrigger.defaultState === "open") {
            bar.visible = true;
            if (typeof bar.barIdx[bar.selectedButton] !== "undefined") {
                bars[bar.barIdx[bar.selectedButton]].visible = true;
            }
        }
        else {
            bar.visible = false;
            for (var i=0; i < bars.length; i++) {
                bars[i].visible = false;
            }
        }
    }

    //check collisions with a bar if it is visible
    //--------------------------------------------
    function testBarCollision(barId, x, y, position, click) {
        if (barId.visible) {
            for (var i=0; i < barId.children.length; i++) {
                if (barId.children[i].objectName === "button") {
                    barId.children[i].testCollision(x,y); //button collision
                }
            }
            if (checkIsOverBar(x, y) && !(changed)) {
                toolbarManager.update_tool('no_mouse');
                changed = true;
            }
            else if (!(checkIsOverBar(x, y)) && changed) {
                changed = false;
            }
            if (click) {
                updateBarState(barId, x, y, position);
                if (position === "bottom")
                    updateSecBarVisibility(barId.barIdx[barId.selectedButton]);
            }
        }
    }

    //check whether the cursor is hovering a bar
    //------------------------------------------j
    function checkIsOverBar(x, y) {
        if ((y >= bar.y + bar.parent.y &&
             y <= bar.y + bar.parent.y + bar.height) || (
             x >= brushBar.x + brushBar.parent.x &&
             x <= brushBar.x + brushBar.parent.x + brushBar.width)) {
            return true;
        }
        return false;
    }



    //check whether we have to update feedback or not
    //------------------------------------------------
    function checkUpdateFeedback(x, y) {
        if (updateFeedback && x < 1650 && y < 750) {
            updateFeedback = false;
            feedbackTimer.start();
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
        if (curr_idx < 3) {
            mainControl.secBar = true;
            mainControl.clearBar = false;
            drawingCanvas.requestPaint();
        } else {
            mainControl.secBar = false;
            mainControl.clearBar = true;
            drawingCanvas.requestPaint();
        }
    }

    //update which object is selected in a bar
    //---------------------------------------
    function updateBarState(barId, x, y, position) {
        for (var i=0; i < barId.children.length; i++) {
            if (barId.children[i].myId === barId.focusedButton) {
                barId.children[i].defaultState = "selected";
                barId.selectedButton = barId.focusedButton;
                updateFeedback = true;
                feedbackImg.source = barId.children[i].imageURL;
            }
            else if (barId.children[i].myId === barId.prevSelected) {
                barId.children[i].defaultState = "unfocused";
            }
        }
        barId.prevSelected = barId.selectedButton;
        barId.collision = false;
        if (checkIsOverBar(x, y)) {
            toolbarManager.update_tool(String(bar.selectedButton));
            toolbarManager.update_tool(String(barId.selectedButton));
        }
    }



    Timer {
        id: feedbackTimert
        interval: 200
        running: false
        repeat: false
        onTriggered: {
            feedback.opacity = 1;
            feedback.x = gaze.x;
            feedback.y = gaze.y;
        }
    }

    Rectangle {
        id: feedback
        height: 100
        width: 100
        color: "#50FFFFFF"
        opacity: 0
        radius: width*0.5
        Image {
            id: feedbackImg
            anchors.centerIn: parent
            sourceSize.height: parent.width*0.7
            sourceSize.width: parent.width*0.7
            fillMode: Image.PreserveAspectFit
            source:""
        }
        onOpacityChanged:
            PropertyAnimation {
                target: feedback
                property: "opacity"
                to: 0
                duration: 1500
                easing.type: Easing.InQuart
            }
    }


    Canvas
    {
        id: drawingCanvas
        anchors.fill: parent
        onPaint:
        {
            var ctx = getContext("2d")
            ctx.lineWidth = 2;

            //second menu
            if (mainControl.secBar) {
                ctx.strokeStyle = "#28afd1";
                ctx.fillStyle = "#28afd1";
                ctx.beginPath();
                ctx.moveTo(1610, 970);
                ctx.lineTo(1800, 970);
                ctx.lineTo(1800, 940);
                ctx.stroke();
                ctx.beginPath();
                ctx.arc(1800, 940, 8, 0, Math.PI*2);
                ctx.fill();
            }

            if (mainControl.clearBar) {
                ctx.clearRect(0,0, drawingCanvas.width, drawingCanvas.height);
            }
        }
    }

    //DEBUG: where the user is looking at
    Rectangle {
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
        color: "transparent"
        visible: true
        border.color: "#28afd1"
        border.width: 2
        radius: 30
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 430
        property var iconSize: appWindow.height

        TriggerManual {
            id: bottomTrigger
            myId: "bottomTrigger"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 50
        }

        RowLayout {
            id: bar
            anchors.centerIn: parent
            spacing: 40
            property var name: "mainBar"
            property var focusedButton: "brush"
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
            spacing: 20
            anchors.centerIn: parent
            property var name: "brushBar"
            property var focusedButton: "brush1"
            property var selectedButton: "brush1"
            property var prevSelected: "brush1"
            property bool collision: false

            EyeButton {
                imageURL: "figs/brush_1.png"
                myId: "brush1"
                fac: 0.8
                Layout.alignment: Qt.AlignHCenter
            }
            EyeButton {
                imageURL: "figs/brush_2.png"
                myId: "brush2"
                fac: 0.8
                Layout.alignment: Qt.AlignHCenter
            }
            EyeButton {
                imageURL: "figs/brush_3.png"
                myId: "brush3"
                fac: 0.8
                Layout.alignment: Qt.AlignHCenter
            }
            EyeButton {
                imageURL: "figs/brush_4.png"
                myId: "brush4"
                fac: 0.8
                Layout.alignment: Qt.AlignHCenter
            }
            EyeButton {
                imageURL: "figs/brush_5.png"
                myId: "brush5"
                fac: 0.8
                Layout.alignment: Qt.AlignHCenter
            }
            EyeButton {
                imageURL: "figs/brush_6.png"
                myId: "brush6"
                fac: 0.8
                Layout.alignment: Qt.AlignHCenter
            }
            EyeButton {
                imageURL: "figs/brush_7.png"
                myId: "brush7"
                fac: 0.8
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }


    SecondaryBar {
        id: selectionBarWindow
        visible: false

        ColumnLayout {
            id: selectionBar
            anchors.centerIn: parent
            spacing: 25
            property var name: "selBar"
            property var focusedButton: "selection1"
            property var selectedButton: "selection1"
            property var prevSelected: "selection1"
            property bool collision: false

            EyeButton {
                imageURL: "figs/selection_square.svg"
                myId: "selection1"
                Layout.alignment: Qt.AlignHCenter
            }
            EyeButton {
                imageURL: "figs/selection_circle.svg"
                myId: "selection2"
                Layout.alignment: Qt.AlignHCenter
            }
            EyeButton {
                imageURL: "figs/selection_contour.svg"
                myId: "selection3"
                Layout.alignment: Qt.AlignHCenter
            }
            EyeButton {
                imageURL: "figs/selection_magic_wand.svg"
                myId: "selection4"
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }


    SecondaryBar {
        id: geometricBarWindow
        visible: false

        ColumnLayout {
            id: geometricBar
            anchors.centerIn: parent
            spacing: 25
            property var name: "geoBar"
            property var focusedButton: "geo1"
            property var selectedButton: "geo1"
            property var prevSelected: "geo1"
            property bool collision: false

            EyeButton {
                imageURL: "figs/painting_square.svg"
                myId: "geo1"
                Layout.alignment: Qt.AlignHCenter
            }
            EyeButton {
                imageURL: "figs/painting_circle.svg"
                myId: "geo2"
                Layout.alignment: Qt.AlignHCenter
            }
            EyeButton {
                imageURL: "figs/path_bezier.svg"
                myId: "geo3"
                Layout.alignment: Qt.AlignHCenter
            }
            EyeButton {
                imageURL: "figs/path_line.svg"
                myId: "geo4"
                Layout.alignment: Qt.AlignHCenter
            }
            EyeButton {
                imageURL: "figs/path_polygon.svg"
                myId: "geo5"
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
