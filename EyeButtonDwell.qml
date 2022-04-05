import QtQuick 2.0

Rectangle {
    id: button
    objectName: "button"
    radius: width*0.5
    property alias imageURL: buttonImg.source
    property string defaultState: "unfocused"
    property var xpos: -1
    property var ypos: -1
    property var rad: -1
    property var myId: -1
    property var fac: 0.65
    property var perc: 0
    property var step: 0
    property var dwellThresh: 31.25 // approx. 500 ms due to animation fixed at 60fps

    Timer {
        id: buttonTimer
        interval: 16
        running: false
        repeat: true
        onTriggered: {
            button.perc = button.perc + button.step;
            buttonCanvas.requestPaint();
        }
    }

    Canvas {
        id: buttonCanvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            var cx = width/2;
            var cy = height/2;

            ctx.beginPath();
            ctx.fillStyle = "orange";
            ctx.moveTo(cx, cy);            
            ctx.arc(cx, cy, width/2, 0, 2*Math.PI*button.perc, false);
            ctx.lineTo(cx, cy);
            ctx.fill();

            ctx.beginPath();
            ctx.fillStyle = button.color;
            ctx.moveTo(cx, cy);
            ctx.arc(cx, cy, width/2.35, 0, 2*Math.PI, false);
            ctx.lineTo(cx, cy);
            ctx.fill();            
        }
    }

    state: defaultState

    Component.onCompleted: {
        button.xpos = button.x + parent.x + parent.parent.x + button.implicitWidth/2;
        button.ypos = button.y + parent.y + parent.parent.y + button.implicitHeight/2;
        button.rad = button.implicitWidth/2;
        button.step = 1.0/button.dwellThresh;
    }

    function testCollision(x, y) {
        var newX = x-button.xpos;
        var newY = y-button.ypos;
        var norm = Math.sqrt(Math.pow(newX, 2) + Math.pow(newY,2));
        if (norm < button.rad) {
            button.state = "focused";
            parent.focusedButton = myId;
            parent.collision = true;
            if (!buttonTimer.running) {
                buttonTimer.start();
            }
            if (button.perc >= 1 && button.state != "selected"){
                button.state = "selected";
            }
        } else {
            button.state = button.defaultState;
            buttonTimer.stop();
            button.perc = 0;
            buttonCanvas.requestPaint();
        }
    }

    states: [
        State {
            name: "unfocused"
            PropertyChanges {
                target: button
                implicitWidth: parent.parent.iconSize/1.5
                implicitHeight: parent.parent.iconSize/1.5
                color: "white"
            }
        },
        State {
            name: "focused"
            PropertyChanges {
                target: button
                implicitWidth: parent.parent.iconSize
                implicitHeight: parent.parent.iconSize
                color: "#ffff99"
            }
        },
        State {
            name: "selected"
            PropertyChanges {
                target: button
                implicitWidth: parent.parent.iconSize/1.5
                implicitHeight: parent.parent.iconSize/1.5
                color: "#5cacf2"
            }
        }
    ]

    transitions: [
        Transition {
            PropertyAnimation {
                properties: "implicitWidth,implicitHeight,color"
                easing.type: Easing.Linear
                duration: 100
            }
        }
    ]

    Image {
        id: buttonImg
        anchors.centerIn: parent
        sourceSize.height: parent.implicitHeight*fac
        sourceSize.width: parent.implicitWidth*fac
        fillMode: Image.PreserveAspectFit
        source:""
    }
}
