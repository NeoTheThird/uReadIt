import QtQuick 2.0
import "QReddit.js" as QReddit

ListModel {
    id: postCommentsListModel

    property string post

    property bool loaded: false
    property bool loading
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
        loading = true;
        var connObj = postObj.getComments('hot', {})
        connObj.onSuccess.connect(function(response) {
            addComments(connObj.response[1], 0);
            loading = false;
            loaded = true;
            loadFinished();
        });
    }

    function addComments(commentsResponse, depth) {
        for (var i = 0; i < commentsResponse.length; i++) {
            var commentObj = commentsResponse[i];
            if (commentObj == undefined) return
            if (commentObj.kind == "more" && commentObj.data.count < 1) return

            commentObj['depth'] = depth
            postCommentsListModel.append(commentObj);

            if (commentObj.data.replies !== undefined && commentObj.data.replies.data !== undefined) {
                addComments(commentObj.data.replies.data.children, depth+1)
            }

        }
    }

}
