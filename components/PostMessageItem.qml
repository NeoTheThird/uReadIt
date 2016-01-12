import QtQuick 2.4
import QtFeedback 5.0
import Ubuntu.Components 1.3
import "../utils/RedditLinker.js" as AutoLinkText

Rectangle {
    id: postMessageItem
    property var postObj

    signal linkActivated(var link)
    width: parent.width
    height: childrenRect.height + units.gu(2)
    anchors.horizontalCenter: parent.horizontalCenter
    color: uReadIt.currentTheme.commentBackgroundColorEven
    anchors.leftMargin: units.gu(5)

    HapticsEffect {
        id: pressEffect
        attackIntensity: 0.0
        attackTime: 50
        intensity: 1.0
        duration: 10
        fadeTime: 50
        fadeIntensity: 0.0
    }

    Label {
        id: name
        anchors.left: parent.left
        anchors.leftMargin: units.gu(1)
        anchors.top: parent.top
        anchors.topMargin: units.gu(1)
        color: uReadIt.currentTheme.messageFontColor
        fontSize: "small"
        font.weight: Font.DemiBold
        text: postObj.data.author
    }

    Label {
        id: body
        width: parent.width - units.gu(2)
        wrapMode: Text.WordWrap
        anchors.left: parent.left
        anchors.leftMargin: units.gu(1)
        anchors.top: name.bottom
        color: uReadIt.currentTheme.messageFontColor
        linkColor: uReadIt.currentTheme.messageLinkColor
        fontSize: "medium"
        textFormat: Text.StyledText

        text: {
            return AutoLinkText.Autolinker.link(postObj.data.selftext || postObj.data.body).replace(/\n/g, "<br>\n")
        }
        onLinkActivated: { pressEffect.start(); postMessageItem.linkActivated(link); }

    }

}
