import QtQuick 2.0
import QtQuick.Layouts 1.3

Rectangle {
    id: secondaryBarWindow
    width: 120
    height: 800
    //color: "green"
    color: "transparent"
    visible: true
    border.color: "#28afd1"
    border.width: 2
    radius: 30
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenterOffset: 830
    property var iconSize: secondaryBarWindow.width

}
