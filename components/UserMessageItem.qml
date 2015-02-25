import QtQuick 2.0
import QtFeedback 5.0
import Ubuntu.Components 1.1
import "../utils/RedditLinker.js" as AutoLinkText

Rectangle {
    id: userMessageItem
    property var messageObj
    color: UbuntuColors.darkGrey
    property string score: parent.score
    property var likes: parent.likes
    property bool read: !messageObj.data.new

    width: parent.width
    height: childrenRect.height
    anchors.horizontalCenter: parent.horizontalCenter

    signal clicked
    signal linkActivated(var link)
    signal upvoteClicked
    signal downvoteClicked
    signal replyClicked
    signal readStatusClicked

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
            color: uReadIt.theme.postItemHeaderColor
            fontSize: "medium"
            font.weight: userMessageItem.read ? Font.Normal : Font.Bold
            text: messageObj && messageObj.data.link_title ? messageObj.data.link_title : ""
            visible: messageObj ? (messageObj.kind === "t1" || messageObj.kind === "t3") : false
            MouseArea {
                anchors.fill: parent
                onClicked: { pressEffect.start(); userMessageItem.clicked(); }
            }
        }

        Label {
            id: name
            anchors.left: parent.left
            anchors.topMargin: units.gu(1)
            color: uReadIt.theme.postItemFontColor
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
            color: uReadIt.theme.postItemFontColor
            linkColor: uReadIt.theme.baseLinkColor
            fontSize: "medium"
            textFormat: Text.StyledText

            text: AutoLinkText.Autolinker.link(messageObj.data.body).replace(/\n/g, "<br>\n")
            onLinkActivated: { pressEffect.start(); userMessageItem.linkActivated(link); }

        }

        Item {
            id: actionsRow
            anchors.left: messageContents.left
            anchors.right: messageContents.right
            height: units.gu(3)

            Icon {
                x: 1*(messageContents.width / 4)-(messageContents.width / 8)-(width/2)
                source: Qt.resolvedUrl("../images/email.svg")
                width: units.gu(2.25)
                height: units.gu(2)
                color: userMessageItem.read ? uReadIt.theme.postItemFontColor : UbuntuColors.orange

                MouseArea {
                    anchors.centerIn: parent
                    height: parent.height * 2
                    width: parent.width * 2
                    onClicked: { pressEffect.start(); readStatusClicked(); }
                }
            }
            Icon {
                x: 2*(messageContents.width / 4)-(messageContents.width / 8)-(width/2)
                source: Qt.resolvedUrl("../images/upvote.png")
                width: units.gu(2)
                height: units.gu(2)
                color: userMessageItem.likes === true ? UbuntuColors.orange : uReadIt.theme.postItemFontColor

                MouseArea {
                    anchors.centerIn: parent
                    height: parent.height * 2
                    width: parent.width * 2
                    onClicked: { pressEffect.start(); upvoteClicked(); }
                }
            }
            Icon {
                x: 3*(messageContents.width / 4)-(messageContents.width / 8)-(width/2)
                source: Qt.resolvedUrl("../images/downvote.png")
                width: units.gu(2)
                height: units.gu(2)
                color: userMessageItem.likes === false ? UbuntuColors.blue : uReadIt.theme.postItemFontColor

                MouseArea {
                    anchors.centerIn: parent
                    height: parent.height * 2
                    width: parent.width * 2
                    onClicked: { pressEffect.start(); downvoteClicked(); }
                }
            }
            Icon {
                x: 4*(messageContents.width / 4)-(messageContents.width / 8)-(width/2)
                //source: Qt.resolvedUrl('../images/comment_16.png')
                name: "new-message"
                width: units.gu(2)
                height: units.gu(2.5)
                color: uReadIt.theme.postItemFontColor

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
