import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0
import "../models/QReddit"
import "../components"
import "../models/QReddit/QReddit.js" as QReddit

Page {
    id: messagesPage
    title: "Messages"

    property string where: 'inbox'

    head.sections {
        model: ['Inbox', 'Unread', 'Sent']
        selectedIndex: where == "inbox" ? 0 : (where == "unread" ? 1 : 2)
        onSelectedIndexChanged: {
            messagesPage.where = head.sections.model[head.sections.selectedIndex].toLowerCase()
        }
    }

    ListView {
        id: messagesList
        anchors.fill: parent

        model: UserMessagesListModel {
            id: commentsModel
            where: messagesPage.where
        }

        delegate: UserMessageItem {
            messageObj: new QReddit.MessageObj(uReadIt.qreddit, model);
            color: (index % 2 == 0) ? uReadIt.theme.commentBackgroundColorEven : uReadIt.theme.commentBackgroundColorOdd
            score: model.data.score
            likes: model.data.likes

            onLinkActivated: uReadIt.openUrl(link);
            onClicked: {
                var messageLink = 'http://reddit.com' + messageObj.data.context
                var contextMatch = messageLink.match(singleCommentUrlRegEx);
                if (contextMatch) {
                    var postConn = uReadIt.qreddit.getPostData(contextMatch[2]);
                    postConn.onSuccess.connect(function() {
                        console.log('post data: '+postConn.response)
                        var postObj = new QReddit.PostObj(qreddit, {'data': postConn.response})
                        console.log('postObj: '+postObj)
                        console.log('postObj.data.title: '+postObj.data.title)
                        mainStack.push(Qt.resolvedUrl("./CommentsPage.qml"), {'postObj': postObj});
                    })
                }
                return;
            }

            onReadStatusClicked: {
                var messageItem = this;
                if (messageObj.data.new) {
                    var readConnObj = messageObj.mark_read();
                    readConnObj.onSuccess.connect(function(response) {
                        messageObj.data.new = false;
                        messageItem.read = true
                        uReadIt.checkForMessages();
                    });
                } else {
                    var unReadConnObj = messageObj.mark_unread();
                    unReadConnObj.onSuccess.connect(function(response) {
                        messageObj.data.new = true;
                        messageItem.read = false
                        uReadIt.checkForMessages();
                    });
                }
            }

            onUpvoteClicked: {
                if (!uReadIt.qreddit.notifier.isLoggedIn) {
                    console.log("You can't vote when you're not logged in!");
                    return;
                }

                var voteConnObj = messageObj.upvote();
                var messageItem = this;
                voteConnObj.onSuccess.connect(function(response){
                    messageItem.likes = model.data.likes = messageObj.data.likes;
                    messageItem.score = model.data.score = messageObj.data.score;
                });
            }
            onDownvoteClicked: {
                if (!uReadIt.qreddit.notifier.isLoggedIn) {
                    console.log("You can't vote when you're not logged in!");
                    return;
                }
                var voteConnObj = messageObj.downvote();
                var messageItem = this;
                voteConnObj.onSuccess.connect(function(response){
                    messageItem.likes = model.data.likes = messageObj.data.likes;
                    messageItem.score = model.data.score = messageObj.data.score;
                });
            }

            onReplyClicked: {
                if (!uReadIt.qreddit.notifier.isLoggedIn) {
                    console.log("You can't reply when you're not logged in!");
                    return;
                }
                mainStack.push(Qt.resolvedUrl("PostMessagePage.qml"), {'replyToObj': messageObj})
            }
        }
    }
}
