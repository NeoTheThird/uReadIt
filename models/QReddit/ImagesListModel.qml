import QtQuick 2.0
import "QReddit.js" as QReddit

ListModel {
    id: imagesListModel

    property string subreddit
    property string filter

    property bool autoLoad: true
    property bool initialized: false
    property bool loading: false
    property bool loaded: false
    signal loadFinished

    property var redditObj: new QReddit.QReddit("QReddit", "qreddit")
    property var subredditObj: redditObj.getSubredditObj(subreddit)

    property string startAfter: ""

    onSubredditChanged: {
        console.log('Subreddit changed to '+subreddit)
        if (!initialized) return;
        clear();
        if (loaded) { startAfter = ""; }
        loaded = false;
        subredditObj = redditObj.getSubredditObj(subreddit);
        load();
    }

    onFilterChanged: {
        console.log('Filter changed to '+filter)
        if (!initialized) return;
        clear();
        if (loaded) { startAfter = ""; }
        loaded = false;
        load();
    }

    Component.onCompleted: if (autoLoad && !loaded) { initialized = true; load(); }

    readonly property var imgurImageRegEx: /https?:\/\/(?:www\.)?imgur\.com\/([\w\d]+)$/
    readonly property string imgurImageEndpoint: 'https://api.imgur.com/3/image/'
    readonly property string imgurImageUrl: 'https://i.imgur.com/'

    function add(postObj) {
        var ext = postObj.data.url.substring(postObj.data.url.lastIndexOf("."))
        if (ext.substring(0, 5) == '.gifv') {
            postObj.data.url = postObj.data.url.substring(0, postObj.data.url.length -1)
            imagesListModel.append(postObj);
            return;
        }
        if (ext.substring(0, 4) == '.gif' || ext.substring(0, 4) == '.jpg' || ext.substring(0, 4) == '.png') {
            imagesListModel.append(postObj);
            return;
        }
        var imgurMatch = postObj.data.url.match(imgurImageRegEx);
        if (imgurMatch) {
            postObj.data.url = imgurImageUrl + imgurMatch[1] + ".jpg"
            imagesListModel.append(postObj);
            return;
        }
    }

    function load() {
        console.log("ImagesListModel.load")
        if (loading) return;// Abort if another load is in progress
        loading = true;
        var connObj = subredditObj.getPostsListing(filter, {'after': startAfter})
        connObj.onSuccess.connect(function(response) {
            for (var i = 0; i < connObj.response.length; i++) {
                var postObj = connObj.response[i];
                add(postObj);
            }

            loaded = true;
            loading = false;
            loadFinished();
        });
    }

    function loadMore() {
        console.log("ImagesListModel.loadMore")
        if (!loaded) return;
        if (loading) return;

        loading = true
        startAfter = subredditObj.data.after
        var moreConnObj = subredditObj.getMoreListing()
        moreConnObj.onSuccess.connect(function(){
            for (var i = 0; i < moreConnObj.response.length; i++) {
                var postObj = moreConnObj.response[i];
                add(postObj);
            }
            loading = false
        })

    }
}
