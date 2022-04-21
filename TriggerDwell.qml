import QtQuick 2.0


Rectangle {
    id: trigger
    objectName: "trigger"
    radius: width*0.5
    property string defaultState: "open"
    property var xpos: -1
    property var ypos: -1
    property var rad: -1
    property var myId: -1
    property bool focused: false
    property var perc: 0
    property var step: 0
    property var dwellThresh: 31.25 //approx. 500 ms due to animation fixed at 60fps
    property bool rest: false
    state: defaultState

    Timer {
        id: triggerTimer
        interval: 16
        running: false
        repeat: true
        onTriggered: {
            trigger.perc += trigger.step;
            triggerCanvas.requestPaint();
        }
    }

    Timer {
        id: dwellRest
        interval: 700
        running: false
        repeat: false
        onTriggered: {
            trigger.rest = false;
        }
    }

    Canvas {
        id: triggerCanvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            var cx = width/2;
            var cy = height/2;

            ctx.beginPath();
            ctx.fillStyle = "orange";
            ctx.moveTo(cx, cy);
            ctx.arc(cx, cy, width/2, 0, 2*Math.PI*trigger.perc, false);
            ctx.lineTo(cx, cy);
            ctx.fill();

            ctx.beginPath();
            ctx.fillStyle = trigger.color;
            ctx.moveTo(cx, cy);
            ctx.arc(cx, cy, width/2.35, 0, 2*Math.PI, false);
            ctx.lineTo(cx, cy);
            ctx.fill();
        }
    }


    Component.onCompleted: {
        trigger.xpos = trigger.x + parent.x + trigger.implicitWidth/2;
        trigger.ypos = trigger.y + parent.y + trigger.implicitHeight/2;
        trigger.rad = trigger.implicitWidth/2;
        trigger.step = 1.0/trigger.dwellThresh;
    }

    function testCollision(x, y) {
        var newX = x-trigger.xpos;
        var newY = y-trigger.ypos;
        var norm = Math.sqrt(Math.pow(newX, 2) + Math.pow(newY,2));
        if (norm < trigger.rad && !trigger.rest) {
            trigger.state = "focused";
            trigger.focused = true;
            if (!triggerTimer.running) {
                triggerTimer.start();
            }
            if (trigger.perc >= 1) {
                trigger.state = trigger.defaultState;
                if (trigger.defaultState == "open") {
                    trigger.defaultState = "closed";
                    parent.border.width = 0;
                    mainControl.clearBar = true;
                    updateDwellState();
                }
                else if (trigger.defaultState == "closed") {
                    trigger.defaultState = "open";
                    parent.border.width = 2;
                    mainControl.clearBar = false;
                    updateDwellState();
                }
                drawingCanvas.requestPaint();
                trigger.rest = true;
                dwellRest.start();
            }
        }
        else {
            trigger.focused = false;
            trigger.state = trigger.defaultState;
            triggerTimer.stop();
            trigger.perc = 0;
            triggerCanvas.requestPaint();
        }
        return trigger.defaultState;
    }

    function updateDwellState() {
        triggerTimer.stop();
        trigger.perc = 0;
        triggerCanvas.requestPaint();
    }

//    function changeDefaultSate() {
//        if (trigger.defaultState == "open") {
//            trigger.defaultState = "closed";
//            parent.border.width = 0;
//            mainControl.clearBar = true;
//            drawingCanvas.requestPaint();
//            console.log("estava open");
//        } else {
//            trigger.defaultState = "open";
//            parent.border.width = 2;
//            mainControl.clearBar = false;
//            drawingCanvas.requestPaint();
//            console.log("estava closed");
//        }
//    }


    states: [
        State {
            name: "open"
            PropertyChanges {
                target: trigger
                implicitWidth: parent.height/2
                implicitHeight: parent.height/2
                color: "#66db0000"
            }
        },
        State {
            name: "focused"
            PropertyChanges {
                target: trigger
                implicitWidth: parent.height/1.5
                implicitHeight: parent.height/1.5
                color: "#b3e1e774"
            }
        },
        State {
            name: "closed"
            PropertyChanges {
                target: trigger
                implicitWidth: parent.height/2
                implicitHeight: parent.height/2
                color: "#66006ddb"
            }
        }
    ]

    transitions: [
        Transition {
            PropertyAnimation {
                properties: "implicitWidth,implicitHeight,color"
                easing.type: Easing.Linear
                duration: 200
            }
        }
    ]


}
