import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0
import "../components"
import "../models/QReddit/QReddit.js" as QReddit

Page {
    id: postMessagePage
    property var replyToObj

    title: 'Post Reply'

    readonly property var commentContextRegEx:   /\/r\/(\w+)\/comments\/(\w+)\/(\w+)\/(\w+)\/?/

    head.backAction: Action {
        id: cancelChangeAction
        text: "Cancel"
        iconName: "close"
        onTriggered: {
            mainStack.pop()
        }
    }
    head.actions: [
        Action {
            id: quoteAction
            text: "Quote"
            iconSource: Qt.resolvedUrl("../images/quote.png")
            onTriggered: {
                message.text = "> "+replyToObj.data.body + "\n" + message.text
                quoteAction.enabled = false;
            }
        },
        Action {
            id: sendAction
            text: "Send"
            iconName: "chevron"
            enabled: message.text != ""
            onTriggered: {
                Qt.inputMethod.commit();
                var msgConnObj = replyToObj.comment(message.text);
                msgConnObj.onSuccess.connect(function(response){
                    mainStack.pop()
                });
            }
        }
    ]
    state: 'default'

    Component.onCompleted: message.forceActiveFocus()
    Flickable {
        id: postMessageContent
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: units.gu(2)
        }
        clip: true
        contentHeight: contentColumn.height
        Column {
            id: contentColumn
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            spacing: units.gu(1)

            Loader {
                id: parentMessage
                width: parent.width
                anchors.leftMargin: units.gu(5)

            }

            PostMessageItem {
                id: replyTo
                postObj: postMessagePage.replyToObj
                width: parent.width
                anchors.left: parent.left
                anchors.leftMargin: (parentMessage.status == Loader.Ready) ? units.gu(1) : units.gu(0)

                color: uReadIt.currentTheme.commentBackgroundColorOdd
                onLinkActivated: uReadIt.openUrl(link);

                ActivityIndicator {
                    id: loadingIndicator
                    anchors.centerIn: parent
                    running: false
                }
            }

            Label {
                id: showParent
                visible: replyToObj.data.context != null
                anchors.left: parent.left
                anchors.leftMargin: units.gu(1)
                color: uReadIt.currentTheme.messageFontColor
                linkColor: uReadIt.currentTheme.messageLinkColor
                fontSize: "medium"
                textFormat: Text.StyledText
                text: "<a href='#'>Show Parent</a>"
                onLinkActivated: {
                    showParent.visible = false;
                    loadingIndicator.running = true;
                    var commentContextParts = replyToObj.data.context.match(commentContextRegEx);
                    if (commentContextParts) {
                        var parentConn = uReadIt.qreddit.getCommentData(commentContextParts[2], replyToObj.data.parent_id.replace("t1_", ""))
                        parentConn .onSuccess.connect(function() {

                            var parentObj = new QReddit.CommentObj(uReadIt.qreddit, {'data': parentConn.response})
                            parentMessage.setSource(Qt.resolvedUrl("../components/PostMessageItem.qml"), {'postObj': parentObj})
                            loadingIndicator.running = false;
                        })
                        parentConn.onError.connect(function() {
                            showParent.visible = true;
                            loadingIndicator.running = false;
                        })
                        return;
                    }
                }
            }

            TextArea {
                id: message
                width: parent.width
                height: units.gu(20)
            }

        }
    }
    clip: uReadIt.height < units.gu(70) ? false : true
    flickable: postMessagePage.clip ? null : postMessageContent
}
