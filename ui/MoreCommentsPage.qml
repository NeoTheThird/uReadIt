import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0
import "../models/QReddit"
import "../components"
import "../utils/Autolinker.js" as AutoLinkText

Page {
    id: commentsPage
    property var postObj
    property var children
    property string link

    title: postObj.data.title

    head.contents: Label {
        text: title
        height: parent ? parent.height : 0
        width: parent ? parent.width : 0
        verticalAlignment: Text.AlignVCenter

        color: "white"
        fontSize: "x-large"
        fontSizeMode: Text.Fit

        maximumLineCount: 3
        minimumPointSize: 8
        elide: Text.Right
        wrapMode: Text.WordWrap
    }

    Component.onCompleted: {
        console.log('Loading comments page for post: '+link)
    }

    ListView {
        id: commentsList
        anchors.fill: parent

        model: MoreCommentsListModel {
            id: commentsModel
            post: commentsPage.postObj.data.id
            more: children
            link: commentsPage.link
        }

        delegate: CommentListItem {
            postObj: commentsPage.postObj
            commentObj: model
            color: (index % 2 == 0) ? Qt.darker('#262626', 1.25) : '#262626'
        }
    }
}
