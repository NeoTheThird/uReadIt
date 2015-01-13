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
            color: (index % 2 == 0) ? Qt.darker('#262626', 1.5) : '#262626'
            score: model.data.score
            likes: model.data.likes

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
