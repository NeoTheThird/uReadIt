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


    ListView {
        id: commentsList
        anchors.fill: parent

        model: PostCommentsListModel {
            id: commentsModel
            post: commentsPage.postObj.data.id
        }

        header:  PostMessageItem {
            postObj: commentsPage.postObj
            color: uReadIt.theme.commentBackgroundColorOdd
            onLinkActivated: uReadIt.openUrl(link);
        }

        delegate: CommentListItem {
            postObj: commentsPage.postObj
            commentObj: new QReddit.CommentObj(uReadIt.qreddit, model);
            color: (index % 2 == 0) ? uReadIt.theme.commentBackgroundColorEven : uReadIt.theme.commentBackgroundColorOdd
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
}
