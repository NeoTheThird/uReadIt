import QtQuick 2.0
import Ubuntu.Components 1.1
import "../utils/Autolinker.js" as AutoLinkText

Item {
    id: commentitemroot
    property var postObj
    property var commentObj
    property color color
    property string score
    property var likes

    width: parent.width
    height: childrenRect.height
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.leftMargin: units.gu(5)

    signal clicked
    signal linkActivated(var link)
    signal upvoteClicked
    signal downvoteClicked
    signal replyClicked

    Loader {
        id: commentItemLoader
        property var postObj: parent.postObj
        property var commentObj: parent.commentObj
        property color color: parent.color
        property string score: parent.score
        property var likes: parent.likes

        width: parent.width

        signal clicked
        signal linkActivated(var link)
        signal upvoteClicked
        signal downvoteClicked
        signal replyClicked
        onClicked: commentitemroot.clicked()
        onLinkActivated: commentitemroot.linkActivated(link)
        onUpvoteClicked: commentitemroot.upvoteClicked()
        onDownvoteClicked: commentitemroot.downvoteClicked()
        onReplyClicked: commentitemroot.replyClicked()

        source: {
            if (commentObj.kind === "t1") {
                return Qt.resolvedUrl("PostCommentItem.qml")
            } else if (commentObj.kind === "more") {
                return Qt.resolvedUrl("MoreCommentsItem.qml")
            }
            return ""
        }
    }

}
