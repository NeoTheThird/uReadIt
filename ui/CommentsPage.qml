import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0
import "../models/QReddit"
import "../components"
import "../utils/Autolinker.js" as AutoLinkText
import "../models/QReddit/QReddit.js" as QReddit

Page {
    id: commentsPage
    property var postObj

    title: postObj.data.title

    head.contents: Label {
        text: title
        height: parent.height
        width: parent.width
        verticalAlignment: Text.AlignVCenter

        fontSize: "x-large"
        fontSizeMode: Text.Fit

        maximumLineCount: 3
        minimumPointSize: 8
        elide: Text.Right
        wrapMode: Text.WordWrap
    }

    head.actions: [
        Action {
            id: replyAction
            text: "Reply"
            iconName: "new-message"
            enabled: uReadIt.qreddit.notifier.isLoggedIn
            onTriggered: {
                var postReplyObj = new QReddit.PostObj(uReadIt.qreddit, postObj)
                mainStack.push(Qt.resolvedUrl("PostMessagePage.qml"), {'replyToObj': postReplyObj})
            }
        }

    ]

    Keys.onPressed: {
        if (event.key == Qt.Key_Home) { commentsList.contentY = 0; return; }

        if (event.key == Qt.Key_PageDown && !commentsList.atYEnd) {
            var nextY = commentsList.contentY + (commentsList.height/2);
            commentsList.contentY = nextY
            return;
        }
        if (event.key == Qt.Key_PageUp && !commentsList.atYBeginning) {
            var prevY = commentsList.contentY - (commentsList.height/2);
            if (prevY < 0) {
                prevY = 0;
            }
            commentsList.contentY = prevY
            return;
        }

    }

    UbuntuListView {
        id: commentsList
        anchors.fill: parent

        Behavior on contentY {
                SmoothedAnimation { duration: 500 }
        }

        model: PostCommentsListModel {
            id: commentsModel
            post: commentsPage.postObj.data.id
        }

        header:  PostMessageItem {
            postObj: commentsPage.postObj
            color: uReadIt.currentTheme.commentBackgroundColorOdd
            onLinkActivated: uReadIt.openUrl(link);
        }

        delegate: CommentListItem {
            postObj: commentsPage.postObj
            commentObj: new QReddit.CommentObj(uReadIt.qreddit, model);
            color: (index % 2 == 0) ? uReadIt.currentTheme.commentBackgroundColorEven : uReadIt.currentTheme.commentBackgroundColorOdd
            score: model.data.score
            likes: model.data.likes

            onLinkActivated: uReadIt.openUrl(link);

            onUpvoteClicked: {
                if (!uReadIt.qreddit.notifier.isLoggedIn) {
                    console.log("You can't vote when you're not logged in!");
                    return;
                }

                var voteConnObj = commentObj.upvote();
                var commentItem = this;
                voteConnObj.onSuccess.connect(function(response){
                    commentItem.likes = model.data.likes = commentObj.data.likes;
                    commentItem.score = model.data.score = commentObj.data.score;
                });
            }
            onDownvoteClicked: {
                if (!uReadIt.qreddit.notifier.isLoggedIn) {
                    console.log("You can't vote when you're not logged in!");
                    return;
                }
                var voteConnObj = commentObj.downvote();
                var commentItem = this;
                voteConnObj.onSuccess.connect(function(response){
                    commentItem.likes = model.data.likes = commentObj.data.likes;
                    commentItem.score = model.data.score = commentObj.data.score;
                });
            }

            onReplyClicked: {
                if (!uReadIt.qreddit.notifier.isLoggedIn) {
                    console.log("You can't reply when you're not logged in!");
                    return;
                }
                mainStack.push(Qt.resolvedUrl("PostMessagePage.qml"), {'replyToObj': commentObj})
            }
        }
    }

    flickable: commentsList//uReadIt.height < units.gu(70) ? commentsList : null
    clip: false//uReadIt.height < units.gu(70) ? false : true

    ActivityIndicator {
        id: loadingIndicator
        anchors.centerIn: parent
        running: commentsModel.loading
    }
}
