import QtQuick 2.0
import Ubuntu.Components 1.1
import "../utils/Autolinker.js" as AutoLinkText

Rectangle {
    id: postMessageItem
    property var postObj

    width: parent.width
    height: childrenRect.height + units.gu(2)
    anchors.horizontalCenter: parent.horizontalCenter
    color: UbuntuColors.lightGrey
    anchors.leftMargin: units.gu(5)

    Label {
        id: name
        anchors.left: parent.left
        anchors.leftMargin: units.gu(1)
        anchors.top: parent.top
        anchors.topMargin: units.gu(1)
        color: Qt.darker(UbuntuColors.warmGrey, 1.5)
        fontSize: "small"
        text: postObj.data.author
    }

    Label {
        id: body
        width: parent.width - units.gu(2)
        wrapMode: Text.WordWrap
        anchors.left: parent.left
        anchors.leftMargin: units.gu(1)
        anchors.top: name.bottom
        color: UbuntuColors.warmGrey
        linkColor: 'lightblue'
        fontSize: "medium"
        textFormat: Text.StyledText

        text: {
            return AutoLinkText.Autolinker.link(postObj.data.selftext || postObj.data.body).replace(/\n/g, "<br>\n")
        }

        onLinkActivated: {
            console.log("Link clicked: "+ link)
            Qt.openUrlExternally(link)
        }
    }

}
