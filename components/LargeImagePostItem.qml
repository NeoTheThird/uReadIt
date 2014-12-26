import QtQuick 2.0
import Ubuntu.Components 1.1

Item {
    id: postitemroot
    property string title: parent.title
    property string text: parent.text
    property string score: parent.score
    property string author: parent.author
    property string domain: parent.domain
    property string thumbnail: parent.thumbnail
    property string url: parent.url
    property string comments: parent.comments


    height: units.gu(36)
    width: parent.width

    Rectangle {
        color: "#222222"
        anchors.fill: parent
        border.color: "#111111"
        Label {
            id: titleLabel
            anchors.left: parent.left
            anchors.leftMargin: units.gu(0.5)
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: units.gu(0.5)
            height: units.gu(3)
            y: parent.y

            fontSize: "medium"
            font.weight: Font.DemiBold
            color: UbuntuColors.warmGrey

            maximumLineCount: 3
            elide: Text.ElideRight
            wrapMode: Text.WordWrap

            text: postitemroot.title
            MouseArea {
                anchors.fill: parent
                onClicked: postitemroot.parent.clicked()
            }
        }

        PostImage {
            id: postThumbnail
            width: sourceSize.width >= sourceSize.height ? parent.width : undefined
            height: sourceSize.width > sourceSize.height ? undefined : units.gu(30)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: titleLabel.height
            anchors.verticalCenter: parent.verticalCenter
            thumbnail: parent.parent.parent.thumbnail
            url: postitemroot.url

            MouseArea {
                anchors.fill: parent
                onClicked: postitemroot.parent.clicked()
            }
        }

        Item {
            id: actionsRow
            width: parent.width
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: units.gu(3)

            Label {
                id: scoreLabel
                text: (postitemroot.score > 0 ? "+" : "")+postitemroot.score
                x: 1*(parent.width / 4)-(parent.width / 8)-(width/2)
                color: score > 100 ? "#55AA55" : score > 10 ? "#5555AA" : UbuntuColors.warmGrey
            }
            Icon {
                x: 2*(parent.width / 4)-(parent.width / 8)-(width/2)
                source: Qt.resolvedUrl("../images/upvote.png")
                width: units.gu(2)
                height: units.gu(2)
                color: UbuntuColors.warmGrey

                MouseArea {
                    anchors.fill: parent
                    onClicked: postitemroot.parent.upvoteClicked()
                }
            }
            Icon {
                x: 3*(parent.width / 4)-(parent.width / 8)-(width/2)
                source: Qt.resolvedUrl("../images/downvote.png")
                width: units.gu(2)
                height: units.gu(2)
                color: UbuntuColors.warmGrey

                MouseArea {
                    anchors.fill: parent
                    onClicked: postitemroot.parent.downvoteClicked()
                }
            }
            BorderIcon {
                x: 4*(parent.width / 4)-(parent.width / 8)-(width/2)
                source: Qt.resolvedUrl('../images/comment_16.png')
                width: Math.max(commentCount.width + units.gu(1), units.gu(2))
                height: units.gu(2.5)
                color: UbuntuColors.warmGrey

                border {
                    left: 8
                    right: 3
                    bottom: 4
                    top: 4
                }

                Text {
                    id: commentCount
                    text: postitemroot.comments
                    color: UbuntuColors.coolGrey
                    font.pixelSize: parent.height - units.gu(1)
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: postitemroot.parent.commentsClicked()
                }
            }
        }

    }

}

