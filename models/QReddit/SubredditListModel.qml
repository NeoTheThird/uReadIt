import QtQuick 2.0
import "QReddit.js" as QReddit

ListModel {
    id: subredditListModel

    property string subreddit
    property string filter

    property bool loaded
    signal loadFinished

    property var redditObj: new QReddit.QReddit("QReddit", "qreddit")
    property var subredditObj: redditObj.getSubredditObj(subreddit)

    onSubredditChanged: {
        //console.log('Subreddit changed to '+subreddit)
        clear();
        subredditObj = redditObj.getSubredditObj(subreddit);
        load();
    }

    onFilterChanged: {
        //console.log('Filter changed to '+filter)
        clear();
        load();
    }

    Component.onCompleted: load()

    function load() {
        var connObj = subredditObj.getPostsListing(filter, {})
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

        var moreConnObj = subredditObj.getMoreListing()
        moreConnObj.onSuccess.connect(function(){
            for (var i = 0; i < moreConnObj.response.length; i++) {
                var postObj = moreConnObj.response[i];
                subredditListModel.append(postObj);
            }
        })

    }
}
