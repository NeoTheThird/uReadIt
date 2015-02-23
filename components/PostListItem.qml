import QtQuick 2.0
import QtFeedback 5.0
import Ubuntu.Components 1.1
import Ubuntu.Connectivity 1.0

Item {
    id: postitemroot
    property string title
    property string text
    property string score
    property string author
    property string domain
    property string thumbnail
    property string url
    property string comments
    property var likes

    signal clicked
    signal upvoteClicked
    signal downvoteClicked
    signal commentsClicked

    height: (postItemLoader.item) ? postItemLoader.item.height : 0
    width: parent ? parent.width : 0

    HapticsEffect {
        id: pressEffect
        attackIntensity: 0.0
        attackTime: 50
        intensity: 1.0
        duration: 10
        fadeTime: 50
        fadeIntensity: 0.0
    }
    Connections {
        target: NetworkingStatus
        // full status can be retrieved from the base C++ class
        // status property
        onStatusChanged: {
            if (status === NetworkingStatus.Offline)
                console.log("Status: Offline")
            if (status === NetworkingStatus.Connecting)
                console.log("Status: Connecting")
            if (status === NetworkingStatus.Online)
                console.log("Status: Online")
        }
    }
    Loader {
        id: postItemLoader
        property string title: parent.title
        property string text: parent.text
        property string score: parent.score
        property string author: parent.author
        property string domain: parent.domain
        property string thumbnail: parent.thumbnail
        property string url: parent.url
        property string comments: parent.comments
        property var likes: parent.likes

        width: parent.width

        signal clicked
        signal upvoteClicked
        signal downvoteClicked
        signal commentsClicked
        onClicked: { pressEffect.start(); postitemroot.clicked(); }
        onUpvoteClicked: { pressEffect.start(); postitemroot.upvoteClicked(); }
        onDownvoteClicked: { pressEffect.start(); postitemroot.downvoteClicked(); }
        onCommentsClicked: { pressEffect.start(); postitemroot.commentsClicked(); }

        source: {
            //console.log('Link: '+url)
            if (uReadIt.settings.showPreviews == uReadIt.settings.previewByConnectivity) {
                if (NetworkingStatus.limitedBandwith) {
                    console.log('Using low-res image to conserve bandwidth')
                    return "SmallImagePostItem.qml";
                }
            }

            var ext = url.substring(url.length - 4)
            if (uReadIt.settings.showPreviews == uReadIt.settings.previewLargeImages) {
                if (thumbnail && (ext == '.gif' || ext == '.jpg')) {
                    return "LargeImagePostItem.qml";
                } else {
                    return "SmallImagePostItem.qml";
                }
            } else if (uReadIt.settings.showPreviews == uReadIt.settings.previewThumbnailsOnly) {
                return "SmallImagePostItem.qml";
            } else if (uReadIt.settings.showPreviews == uReadIt.settings.previewNone) {
                parent.thumbnail = '';
                return "SmallImagePostItem.qml";
            } else {
                //return "SmallImagePostItem.qml";
            }
        }
    }

}
