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

    state: defaultState

    Component.onCompleted: {
        button.xpos = button.x + parent.x + parent.parent.x + button.implicitWidth/2;
        button.ypos = button.y + parent.y + parent.parent.y + button.implicitHeight/2;
        button.rad = button.implicitWidth/2;
    }

    function testCollision(x, y) {
        var newX = x-button.xpos;
        var newY = y-button.ypos;
        var norm = Math.sqrt(Math.pow(newX, 2) + Math.pow(newY,2));
        if (norm < button.rad) {
            button.state = "focused";
            bar.selectedButton = myId;
            bar.collision = true;
        } else {
            button.state = defaultState;
        }
    }

    states: [
        State {
            name: "unfocused"
            PropertyChanges {
                target: button
                implicitWidth: appWindow.height/1.5
                implicitHeight: appWindow.height/1.5
                color: "white"
            }
        },
        State {
            name: "focused"
            PropertyChanges {
                target: button
                implicitWidth: appWindow.height
                implicitHeight: appWindow.height
                color: "#ffff99"
            }
        },
        State {
            name: "selected"
            PropertyChanges {
                target: button
                implicitWidth: appWindow.height/1.5
                implicitHeight: appWindow.height/1.5
                color: "#5cacf2"
            }
        }
    ]

    transitions: [
        Transition {
            PropertyAnimation {
                properties: "implicitWidth,implicitHeight,color"
                easing: Easing.Linear
                duration: 150
            }
        }
    ]

    Image {
        id: buttonImg
        anchors.centerIn: parent
        sourceSize.height: parent.implicitHeight*0.65
        sourceSize.width: parent.implicitWidth*0.65
        fillMode: Image.PreserveAspectFit
        source:""
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            parent.state = "focused";
        }
        onExited: {
            parent.state  = defaultState;
        }
    }
}
