import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0
import "../components"

Page {
    id: postMessagePage
    property var replyToObj

    title: 'Post Reply'

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

            PostMessageItem {
                id: replyTo
                postObj: postMessagePage.replyToObj
                width: parent.width
                color: uReadIt.currentTheme.commentBackgroundColorOdd
                onLinkActivated: uReadIt.openUrl(link);
            }

            TextArea {
                id: message
                width: parent.width
                height: units.gu(20)
            }

        }
    }
}
