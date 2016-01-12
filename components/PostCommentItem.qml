import QtQuick 2.4
import QtFeedback 5.0
import Ubuntu.Components 1.3
import "../utils/RedditLinker.js" as AutoLinkText

Rectangle {
    id: postCommentItem
    property var postObj: parent.postObj
    property var commentObj: parent.commentObj
    color: parent.color
    property string score: parent.score
    property var likes: parent.likes

    width: parent.width
    height: childrenRect.height
    anchors.horizontalCenter: parent.horizontalCenter

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
        id: commentContents
        anchors.left: parent.left
        anchors.leftMargin: units.gu((commentObj ? commentObj.depth : 0)+1)
        anchors.right: parent.right
        Label {
            id: name
            anchors.left: parent.left
            anchors.topMargin: units.gu(1)
            color: uReadIt.currentTheme.commentFontColor
            fontSize: "small"
            font.weight: Font.DemiBold
            text: commentObj ? commentObj.data.author : ""
            visible: commentObj ? (commentObj.kind === "t1" || commentObj.kind === "t3") : false
        }

        Label {
            id: body
            width: parent.width - units.gu(depth+2)
            wrapMode: Text.WordWrap
            anchors.left: parent.left
            anchors.right: parent.right
            color: uReadIt.currentTheme.commentFontColor
            linkColor: uReadIt.currentTheme.commentLinkColor
            fontSize: "medium"
            textFormat: Text.StyledText

            text: AutoLinkText.Autolinker.link(commentObj.data.body).replace(/\n/g, "<br>\n")

            onLinkActivated: { pressEffect.start(); postCommentItem.parent.linkActivated(link); }
        }

        Item {
            id: actionsRow
            anchors.left: commentContents.left
            anchors.right: commentContents.right
            height: units.gu(3)

            Label {
                id: scoreLabel
                text: (postCommentItem.score > 0 ? "+" : "")+postCommentItem.score
                x: 1*(commentContents.width / 4)-(commentContents.width / 8)-(width/2)
                color: postCommentItem.score > 100 ? "#55AA55" : postCommentItem.score > 10 ? "#5555AA" : uReadIt.currentTheme.commentFontColor
            }
            Icon {
                x: 2*(commentContents.width / 4)-(commentContents.width / 8)-(width/2)
                source: Qt.resolvedUrl("../images/upvote.png")
                width: units.gu(2)
                height: units.gu(2)
                color: postCommentItem.likes === true ? UbuntuColors.orange : uReadIt.currentTheme.commentFontColor

                MouseArea {
                    anchors.centerIn: parent
                    height: parent.height * 2
                    width: parent.width * 2
                    onClicked: { pressEffect.start(); postCommentItem.parent.upvoteClicked(); }
                }
            }
            Icon {
                x: 3*(commentContents.width / 4)-(commentContents.width / 8)-(width/2)
                source: Qt.resolvedUrl("../images/downvote.png")
                width: units.gu(2)
                height: units.gu(2)
                color: postCommentItem.likes === false ? UbuntuColors.blue : uReadIt.currentTheme.commentFontColor

                MouseArea {
                    anchors.centerIn: parent
                    height: parent.height * 2
                    width: parent.width * 2
                    onClicked: { pressEffect.start(); postCommentItem.parent.downvoteClicked(); }
                }
            }
            Icon {
                x: 4*(commentContents.width / 4)-(commentContents.width / 8)-(width/2)
                //source: Qt.resolvedUrl('../images/comment_16.png')
                name: "new-message"
                width: units.gu(2)
                height: units.gu(2.5)
                color: uReadIt.currentTheme.commentFontColor

                MouseArea {
                    anchors.centerIn: parent
                    height: parent.height * 2
                    width: parent.width * 2
                    onClicked: { pressEffect.start(); postCommentItem.parent.replyClicked(); }
                }
            }
        }
    }
}
