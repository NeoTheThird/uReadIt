import QtQuick 2.0
import "QReddit.js" as QReddit

ListModel {
    id: userMessagesListModel

    property string where

    property bool loaded: false
    signal loadFinished

    property var redditObj: new QReddit.QReddit("QReddit", "qreddit")
    property var userObj: new QReddit.UserObj(uReadIt.qreddit.notifier.activeUser)

    onWhereChanged: {
        //console.log('Filter changed to '+filter)
        clear();
        load();
    }

    Component.onCompleted: load()

    function load() {
        var userObj = redditObj.getUserObj(redditObj.getActiveUser());
        var connObj = userObj.getMessageListing(where, {});
        connObj.onSuccess.connect(function(response) {
            for (var i = 0; i < connObj.response.length; i++) {
                var msgObj = connObj.response[i];
                userMessagesListModel.append(msgObj);
            }

            loadFinished();
            loaded = true;

        });
    }


}
