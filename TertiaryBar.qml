import QtQuick 2.0
import QtQuick.Layouts 1.3

Rectangle {
    id: tertiaryBarWindow
    width: 800
    height: 120
    //color: "green"
    color: "transparent"
    visible: true
    border.color: "#28afd1"
    border.width: 2
    radius: 30
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenterOffset: -430
    property var iconSize: tertiaryBarWindow.width

}
