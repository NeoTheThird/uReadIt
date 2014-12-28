import QtQuick 2.0
import "QReddit.js" as QReddit

ListModel {
    id: moreCommentsListModel

    property var post
    property var more
    property string link

    property bool loaded
    signal loadFinished

    property var redditObj: new QReddit.QReddit("QReddit", "qreddit")
    property var postObj: new QReddit.PostObj(redditObj, {'data': {'id': post}})
    property var moreObj: new QReddit.MoreObj(redditObj, {'data': {'parent_id': postObj.data.name, 'children': more}}, link)

    onPostChanged: {
        console.warn('Changing post on a PostCommentsListModel is not supported')
    }

    onMoreChanged: {
        console.warn('Changing comments on a MoreCommentsListModel is not supported')
    }

    Component.onCompleted: { console.log('Link: '+link); load(); }

    function load() {
        if (moreObj == undefined) {
            console.log('moreObj is not defined, aborting comments load')
            return
        }

        var connObj = moreObj.getMoreComments('hot')
        connObj.onSuccess.connect(function() {
            addComments(connObj.response, 0);
        });
    }

    function addComments(commentsResponse, depth) {
        for (var i = 0; i < commentsResponse.length; i++) {
            var commentObj = commentsResponse[i];
            if (commentObj == undefined) return
            if (commentObj.kind == "more" && commentObj.data.count < 1) return

            commentObj['depth'] = depth
            moreCommentsListModel.append(commentObj);

            if (commentObj.data.replies !== undefined && commentObj.data.replies.data !== undefined) {
                addComments(commentObj.data.replies.data.children, depth+1)
            }

        }
    }

}
