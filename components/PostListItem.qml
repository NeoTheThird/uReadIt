import QtQuick 2.0
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

    signal clicked
    signal upvoteClicked
    signal downvoteClicked
    signal commentsClicked

    height: postItemLoader.item.height
    width: parent.width

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

        width: parent.width

        signal clicked
        signal upvoteClicked
        signal downvoteClicked
        signal commentsClicked
        onClicked: postitemroot.clicked()
        onUpvoteClicked: postitemroot.upVoteClicked()
        onDownvoteClicked: postitemroot.downVoteClicked()
        onCommentsClicked: postitemroot.commentsClicked()

        onOpacityChanged: console.log('Opacity set to '+opacity)

        source: {
            //console.log('Link: '+url)
            if (NetworkingStatus.limitedBandwith) {
                console.log('Using low-res image to conserve bandwidth')
                return "SmallImagePostItem.qml";
            }

            var ext = url.substring(url.length - 4)
            if (ext == '.gif' || ext == '.jpg') {
                return "LargeImagePostItem.qml";
            } else {
                return "SmallImagePostItem.qml";
            }

        }
    }

}
