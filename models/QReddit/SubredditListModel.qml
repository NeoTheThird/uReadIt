import QtQuick 2.0
import "QReddit.js" as QReddit

ListModel {
    id: subredditListModel

    property string subreddit
    property string filter

    property bool autoLoad: true
    property bool loaded: false
    signal loadFinished

    property var redditObj: new QReddit.QReddit("QReddit", "qreddit")
    property var subredditObj: redditObj.getSubredditObj(subreddit)

    property string startAfter: ""

    onSubredditChanged: {
        //console.log('Subreddit changed to '+subreddit)
        clear();
        if (loaded) { startAfter = ""; }
        loaded = false;
        subredditObj = redditObj.getSubredditObj(subreddit);
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
        var connObj = subredditObj.getPostsListing(filter, {'after': startAfter})
        connObj.onSuccess.connect(function(response) {
            for (var i = 0; i < connObj.response.length; i++) {
                var postObj = connObj.response[i];
                subredditListModel.append(postObj);
            }

            loadFinished();
            loaded = true;
        });
    }

    function loadMore() {
        if (!loaded) {
            return;
        }

        startAfter = subredditObj.data.after
        var moreConnObj = subredditObj.getMoreListing()
        moreConnObj.onSuccess.connect(function(){
            for (var i = 0; i < moreConnObj.response.length; i++) {
                var postObj = moreConnObj.response[i];
                subredditListModel.append(postObj);
            }
        })

    }
}
