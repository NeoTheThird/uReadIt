import QtQuick 2.0
import Ubuntu.Components 1.1
import "../utils/Autolinker.js" as AutoLinkText

Rectangle {
    id: commentListItem
    property var postObj
    property var commentObj

    width: parent.width
    height: childrenRect.height + units.gu(2)
    anchors.horizontalCenter: parent.horizontalCenter
    color: UbuntuColors.lightGrey
    anchors.leftMargin: units.gu(5)

    Label {
        id: name
        anchors.left: parent.left
        anchors.leftMargin: units.gu((commentObj ? commentObj.depth : 0)+1)
        anchors.top: parent.top
        anchors.topMargin: units.gu(1)
        color: Qt.darker(UbuntuColors.warmGrey, 1.5)
        fontSize: "small"
        text: commentObj ? commentObj.data.author : ""
        visible: commentObj ? (commentObj.kind === "t1" || commentObj.kind === "t3") : false
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

        text: {
            if (commentObj.kind === "t1") {
                return AutoLinkText.Autolinker.link(commentObj.data.body).replace(/\n/g, "<br>\n")
            } else if (commentObj.kind === "more") {
                return ''+commentObj.data.count+' more comments...'
            }
        }

        onLinkActivated: {
            console.log("Link clicked: "+ link)
            Qt.openUrlExternally(link)
        }
    }
    MouseArea {
        anchors {
            top: name.top
            left: parent.left
            right: parent.right
            bottom: body.bottom
        }
        onClicked: {
            if (!commentObj) return;
            if (commentObj.kind === "more") {
                mainStack.push(Qt.resolvedUrl('../ui/MoreCommentsPage.qml'), {'postObj': postObj, 'children': commentObj.data.children, 'link': postObj.data.name})
            } else {
                console.log('Clicked comment type: '+commentObj.kind)
            }
        }
    }


}
