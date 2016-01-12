import QtQuick 2.0
import "QReddit.js" as QReddit

ListModel {
    id: multisListModel

    property string multis
    property string filter

    property bool autoLoad: true
    property bool loading: false
    property bool loaded: false
    signal loadFinished

    property var redditObj: new QReddit.QReddit("QReddit", "qreddit")
    property var multisObj: redditObj.getMultisObj(multis)

    property string startAfter: ""

    onMultisChanged: {
        //console.log('Subreddit changed to '+subreddit)
        clear();
        if (loaded) { startAfter = ""; }
        loaded = false;
        multisObj = redditObj.getMultisObj(multis);
        load();
    }

    onFilterChanged: {
        //console.log('Filter changed to '+filter)
        clear();
        if (loaded) { startAfter = ""; }
        loaded = false;
        load();
    }

    Component.onCompleted: if (autoLoad && !loaded) { load(); }

    function load() {
        loading = true;
        var connObj = multisObj.getPostsListing(filter, {'after': startAfter})
        connObj.onSuccess.connect(function(response) {
            for (var i = 0; i < connObj.response.length; i++) {
                var postObj = connObj.response[i];
                multisListModel.append(postObj);
            }

            loaded = true;
            loading = false;
            loadFinished();
        });
    }

    function loadMore() {
        if (!loaded) {
            return;
        }

        loading = true
        startAfter = multisObj.data.after
        var moreConnObj = multisObj.getMoreListing()
        moreConnObj.onSuccess.connect(function(){
            for (var i = 0; i < moreConnObj.response.length; i++) {
                var postObj = moreConnObj.response[i];
                multisListModel.append(postObj);
            }
            loading = false
        })

    }
}
