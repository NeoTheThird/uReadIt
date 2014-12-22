import QtQuick 2.0
import "QReddit.js" as QReddit

ListModel {
    id: postCommentsListModel

    property string post

    property bool loaded
    signal loadFinished

    property var redditObj: new QReddit.QReddit("QReddit", "qreddit")
    property var postObj: new QReddit.PostObj(redditObj, {'data': {'id': post}})

    onPostChanged: {
        console.warn('Changing post on a PostCommentsListModel is not supported')
    }

    Component.onCompleted: load()

    function load() {
        if (postObj == undefined) {
            console.log('postObj is not defined, aborting comments load')
            return
        }

        var connObj = postObj.getComments('hot', {})
        connObj.onSuccess.connect(function(response) {
            //console.log("Connection Succeeded")
            addComments(connObj.response[1], 0);
        });
    }

    function addComments(commentsResponse, depth) {
        for (var i = 0; i < commentsResponse.length; i++) {
            var commentObj = commentsResponse[i];
            if (commentObj == undefined) return

            commentObj['depth'] = depth
            postCommentsListModel.append(commentObj);

            if (commentObj.data.replies !== undefined && commentObj.data.replies.data !== undefined) {
                addComments(commentObj.data.replies.data.children, depth+1)
            }

        }
    }

}
