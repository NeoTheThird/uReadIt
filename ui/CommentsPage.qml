import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0
import "../models/QReddit"
import "../components"
import "../utils/Autolinker.js" as AutoLinkText

Page {
    id: commentsPage
    property var postObj

    title: postObj.data.title

    head.contents: Label {
        text: title
        height: parent.height
        width: parent.width
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
        console.log('Loading comments page for post: '+postObj.data.id)
    }

    ListView {
        id: commentsList
        anchors.fill: parent

        model: PostCommentsListModel {
            id: commentsModel
            post: commentsPage.postObj.data.id
        }

        header:  PostMessageItem {
            postObj: commentsPage.postObj
            color:'#262626'
        }

        delegate: CommentListItem {
            postObj: commentsPage.postObj
            commentObj: model
            color: (index % 2 == 0) ? Qt.darker('#262626', 1.5) : '#262626'
        }
    }
}
