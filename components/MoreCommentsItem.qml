import QtQuick 2.0
import Ubuntu.Components 1.1
import "../utils/Autolinker.js" as AutoLinkText

Rectangle {
    id: commentListItem
    property var postObj: parent.postObj
    property var commentObj: parent.commentObj
    color: parent.color

    width: parent.width
    height: units.gu(4)
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.leftMargin: units.gu(5)

    Label {
        id: body
        width: parent.width - units.gu(depth+2)
        wrapMode: Text.WordWrap
        anchors.left: parent.left
        anchors.leftMargin: units.gu(depth+1)
        anchors.verticalCenter: parent.verticalCenter
        color: 'lightblue'
        fontSize: "medium"
        textFormat: Text.StyledText

        text: commentObj.data.count+' more comments...'

    }
    MouseArea {
        anchors.fill: parent
        onClicked: {
            console.log('More Comments clicked')
            mainStack.push(Qt.resolvedUrl('../ui/MoreCommentsPage.qml'), {'postObj': postObj, 'children': commentObj.data.children, 'link': postObj.data.name})
        }
    }


}
