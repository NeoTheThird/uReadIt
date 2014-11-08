import QtQuick 2.0
import Ubuntu.Components 1.1

Item {
    property alias title: titleLabel.text
    property alias text: selfTextLabel.text
    property string score
    property alias author: authorLabel.text
    property string domain
    property alias thumbnail: postThumbnail.source

    height: postThumbnail.height > 0 ? units.gu(19) : titleLabel.height + authorLabel.height + actionsRow.height + (text == "" ? units.gu(3) : units.gu(10))
    //width: parent.width

    Rectangle {
        color: "#222222"
        anchors.fill: parent
        border.color: "#111111"

        Image {
            id: postThumbnail
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: source == "" ? 0 : units.gu(1)
            height: source == "" ? 0 : units.gu(15)
            width: source == "" ? 0 : units.gu(15)
            fillMode: Image.PreserveAspectCrop
        }

        Label {
            id: titleLabel
            anchors.left: postThumbnail.right
            anchors.leftMargin: units.gu(1)
            anchors.right: parent.right
            y: parent.y

            fontSize: "medium"
            font.weight: Font.DemiBold
            color: UbuntuColors.lightGrey

            maximumLineCount: 3
            elide: Text.ElideRight
            wrapMode: Text.WordWrap
        }

        Label {
            id: authorLabel
            anchors.left: postThumbnail.right
            anchors.leftMargin: units.gu(1)
            anchors.top: titleLabel.bottom
            anchors.right: domainLabel.left
            fontSize: "small"
            font.weight: Font.Light
            color: UbuntuColors.lightGrey
            elide: Text.ElideRight
        }

        Label {
            id: domainLabel
            anchors.right: parent.right
            anchors.rightMargin: units.gu(1)
            anchors.top: titleLabel.bottom
            fontSize: "small"
            font.weight: Font.Light
            color: UbuntuColors.lightGrey
            text: domain ? "("+domain+")" : ""
        }

        Label {
            id: selfTextLabel
            anchors.left: postThumbnail.right
            anchors.leftMargin: units.gu(1)
            anchors.right: parent.right
            anchors.top: authorLabel.bottom
            anchors.bottom: actionsRow.top

            fontSize: "small"
            font.weight: Font.Light
            color: UbuntuColors.lightGrey

            elide: Text.ElideRight
            wrapMode: Text.WordWrap
        }

        Item {
            id: actionsRow
            width: parent.width - units.gu(17)
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: units.gu(3)

            Label {
                id: scoreLabel
                text: (score > 0 ? "+" : "")+score
                x: 1*(parent.width / 4)-(parent.width / 8)-(width/2)
                color: score > 100 ? "#55AA55" : score > 10 ? "#5555AA" : UbuntuColors.lightGrey
            }
            Image {
                x: 2*(parent.width / 4)-(parent.width / 8)-(width/2)
                source: Qt.resolvedUrl("../images/upvote.png")
                width: units.gu(2)
                height: units.gu(2)
            }
            Image {
                x: 3*(parent.width / 4)-(parent.width / 8)-(width/2)
                source: Qt.resolvedUrl("../images/downvote.png")
                width: units.gu(2)
                height: units.gu(2)
            }
            Image {
                x: 4*(parent.width / 4)-(parent.width / 8)-(width/2)
                source: Qt.resolvedUrl("image://theme/message")
                width: units.gu(2)
                height: units.gu(2)
            }
        }
    }

}
