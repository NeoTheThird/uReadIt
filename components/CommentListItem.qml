import QtQuick 2.0
import Ubuntu.Components 0.1

Rectangle {
    property alias text: body.text
    property alias author: name.text
    property int depth: 0
    property bool collapsed: false
    property var listmodel;
    width: parent.width
    height: childrenRect.height + units.gu(2)
    anchors.horizontalCenter: parent.horizontalCenter
    color: UbuntuColors.lightGrey
    anchors.leftMargin: units.gu(5)

    Label {
        id: name
        anchors.left: parent.left
        anchors.leftMargin: units.gu(depth+1)
        anchors.top: parent.top
        anchors.topMargin: units.gu(1)
        color: UbuntuColors.warmGrey
        fontSize: "small"
    }

    Label {
        id: body
        width: parent.width - units.gu(depth+2)
        wrapMode: Text.WordWrap
        anchors.left: parent.left
        anchors.leftMargin: units.gu(depth+1)
        anchors.top: name.bottom
        color: UbuntuColors.warmGrey
        linkColor: 'lightblue'
        fontSize: "medium"
        textFormat: Text.StyledText

        onLinkActivated: {
            console.log("Link clicked: "+ link)
            Qt.openUrlExternally(link)
        }
    }

}
