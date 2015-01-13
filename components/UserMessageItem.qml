import QtQuick 2.0
import QtFeedback 5.0
import Ubuntu.Components 1.1
import "../utils/Autolinker.js" as AutoLinkText

Rectangle {
    id: userMessageItem
    property var messageObj
    color: UbuntuColors.darkGrey
    property string score: parent.score
    property var likes: parent.likes

    width: parent.width
    height: childrenRect.height
    anchors.horizontalCenter: parent.horizontalCenter

    signal clicked
    signal upvoteClicked
    signal downvoteClicked
    signal replyClicked

    HapticsEffect {
        id: pressEffect
        attackIntensity: 0.0
        attackTime: 50
        intensity: 1.0
        duration: 10
        fadeTime: 50
        fadeIntensity: 0.0
    }

    Column {
        id: messageContents
        anchors.topMargin: units.gu(1)
        anchors.left: parent.left
        anchors.leftMargin: units.gu(1)
        anchors.right: parent.right
        spacing: units.gu(1)
        Label {
            id: title
            anchors.left: parent.left
            anchors.topMargin: units.gu(1)
            color: 'lightblue'
            fontSize: "medium"
            font.weight: messageObj.data.new ? Font.Bold : Font.Normal
            text: messageObj && messageObj.data.link_title ? messageObj.data.link_title : ""
            visible: messageObj ? (messageObj.kind === "t1" || messageObj.kind === "t3") : false
        }

        Label {
            id: name
            anchors.left: parent.left
            anchors.topMargin: units.gu(1)
            color: Qt.darker(UbuntuColors.warmGrey, 1.5)
            fontSize: "small"
            text: messageObj ? messageObj.data.author : ""
            visible: messageObj ? (messageObj.kind === "t1" || messageObj.kind === "t3") : false
        }

        Label {
            id: body
            width: parent.width - units.gu(depth+2)
            wrapMode: Text.WordWrap
            anchors.left: parent.left
            anchors.right: parent.right
            color: UbuntuColors.warmGrey
            linkColor: 'lightblue'
            fontSize: "medium"
            textFormat: Text.StyledText

            text: AutoLinkText.Autolinker.link(messageObj.data.body).replace(/\n/g, "<br>\n")

            onLinkActivated: {
                console.log("Link clicked: "+ link)
                Qt.openUrlExternally(link)
            }
        }

        Item {
            id: actionsRow
            anchors.left: messageContents.left
            anchors.right: messageContents.right
            height: units.gu(3)

            Icon {
                x: 1*(messageContents.width / 3)-(messageContents.width / 6)-(width/2)
                source: Qt.resolvedUrl("../images/upvote.png")
                width: units.gu(2)
                height: units.gu(2)
                color: userMessageItem.likes === true ? UbuntuColors.orange : UbuntuColors.warmGrey

                MouseArea {
                    anchors.centerIn: parent
                    height: parent.height * 2
                    width: parent.width * 2
                    onClicked: { pressEffect.start(); upvoteClicked(); }
                }
            }
            Icon {
                x: 2*(messageContents.width / 3)-(messageContents.width / 6)-(width/2)
                source: Qt.resolvedUrl("../images/downvote.png")
                width: units.gu(2)
                height: units.gu(2)
                color: userMessageItem.likes === false ? UbuntuColors.blue : UbuntuColors.warmGrey

                MouseArea {
                    anchors.centerIn: parent
                    height: parent.height * 2
                    width: parent.width * 2
                    onClicked: { pressEffect.start(); downvoteClicked(); }
                }
            }
            Icon {
                x: 3*(messageContents.width / 3)-(messageContents.width / 6)-(width/2)
                //source: Qt.resolvedUrl('../images/comment_16.png')
                name: "new-message"
                width: units.gu(2)
                height: units.gu(2.5)
                color: UbuntuColors.warmGrey

                MouseArea {
                    anchors.centerIn: parent
                    height: parent.height * 2
                    width: parent.width * 2
                    onClicked: { pressEffect.start(); replyClicked(); }
                }
            }
        }
    }
}
