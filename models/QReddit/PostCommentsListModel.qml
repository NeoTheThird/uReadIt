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
            for (var i = 0; i < connObj.response[1].length; i++) {
                var commentObj = connObj.response[1][i];
                postCommentsListModel.append(commentObj);
            }

        });
    }

}
