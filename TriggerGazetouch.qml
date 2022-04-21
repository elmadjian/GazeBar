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

    state: defaultState

    Component.onCompleted: {
        trigger.xpos = trigger.x + parent.x + trigger.implicitWidth/2;
        trigger.ypos = trigger.y + parent.y + trigger.implicitHeight/2;
        trigger.rad = trigger.implicitWidth/2;
    }

    function testCollision(x, y, click) {
        var newX = x-trigger.xpos;
        var newY = y-trigger.ypos;
        var norm = Math.sqrt(Math.pow(newX, 2) + Math.pow(newY,2));
        if (norm < trigger.rad) {
            trigger.state = "focused";
            trigger.focused = true;
            if (click) {
                if (trigger.defaultState == "open") {
                    trigger.defaultState = "closed";
                    parent.border.width = 0;
                    mainControl.clearBar = true;
                    drawingCanvas.requestPaint();
                } else {
                    trigger.defaultState = "open";
                    parent.border.width = 2;
                    mainControl.clearBar = false;
                    drawingCanvas.requestPaint();
                }
                trigger.focused = false;
            }
        }
        else {
            trigger.state = trigger.defaultState;
            trigger.focused = false;
        }
        return trigger.defaultState;
    }


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
