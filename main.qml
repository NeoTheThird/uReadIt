import QtQuick 2.0
import Ubuntu.Components 1.1
import Qt.labs.settings 1.0

import "ui"
import "models/QReddit/QReddit.js" as QReddit
import "themes" as Themes

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    id: uReadIt
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    //applicationName: "com.ubuntu.developer.mhall119.ureadit"
    applicationName: "com.ubuntu.developer.mhall119.ureadit-dev"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    automaticOrientation: true

    // Removes the old toolbar and enables new features of the new header.
    useDeprecatedToolbar: false

    // Make room for the keyboard
    anchorToKeyboard: true

    width: units.gu(100)
    height: units.gu(75)

    property var theme: Themes.ThemeManager {
        id: theme
        name: settings.themeName
    }

    //headerColor: "#333333"
    backgroundColor: theme.backgroundColor
    //footerColor: "#555555"

    property var qreddit: new QReddit.QReddit("uReadIt", "ureadit");

    property var settings: Settings {
        property bool autoLogin: true
        property bool useInternalBrowser: true
        property string themeName: "RedditDark.qml"

        readonly property int previewNone: 0
        readonly property int previewLargeImages: 1
        readonly property int previewThumbnailsOnly: 2
        readonly property int previewByConnectivity: 3
        property int showPreviews: previewLargeImages
    }

    Component.onCompleted: {
        if (settings.autoLogin && qreddit.notifier.activeUser != "") {
            var connObj = qreddit.loginActiveUser();
            connObj.onSuccess.connect(function() {
                frontpage.reload();
                mainStack.push(frontpage);
                console.log('args.values: '+args.values)
                console.log('args.values.url: '+args.values.url)
                if (args.values.url) {
                    openRedditUrl(args.values.url)
                }
            })
        } else {
            mainStack.push(frontpage);
            frontpage.reload();
            console.log('args.values: '+args.values)
            console.log('args.values.url: '+args.values.url)
            if (args.values.url) {
                openRedditUrl(args.values.url)
            }
        }
    }

    PageStack {
        id: mainStack
        anchors.fill: parent
    }

    Frontpage {
        id: frontpage
        subreddit: ''
        StateSaver.properties: "subreddit"
        visible: false
        autoLoad: false
    }

    function checkForMessages() {
        if (uReadIt.qreddit.notifier.isLoggedIn) {
            var userObj = uReadIt.qreddit.getUserObj(uReadIt.qreddit.getActiveUser());
            userObj.updateUnread();
        }
    }

    Timer {
        id: messageChecker
        interval: 30000;
        running: false;
        repeat: true
        onTriggered: checkForMessages();
    }

    Connections {
        target: uReadIt.qreddit.notifier

        onIsLoggedInChanged: {
            if (uReadIt.qreddit.notifier.isLoggedIn) {
                checkForMessages();
                messageChecker.start();
            } else {
                messageChecker.stop();
            }
        }
    }

    Arguments {
        id: args

        Argument {
            name: "url"
            help: "Link to a Reddit thread"
            required: false
            valueNames: ["URL"]
        }
    }

    readonly property var baseRedditUrlRegEx: /https?:\/\/(?:www\.)?reddit\.com\/r\//
    readonly property var subredditThreadUrlRegEx: /https?:\/\/(?:www\.)?reddit\.com\/r\/(\w+)\/?/
    readonly property var commentThreadUrlRegEx:   /https?:\/\/(?:www\.)?reddit\.com\/r\/(\w+)\/comments\/(\w+)\/(\w+)\/?/
    readonly property var singleCommentUrlRegEx:   /https?:\/\/(?:www\.)?reddit\.com\/r\/(\w+)\/comments\/(\w+)\/(\w+)\/(\w+)\/?/

    function openUrl(url) {
        var baseUrlMatch = url.match(baseRedditUrlRegEx);
        if (baseUrlMatch) {
            openRedditUrl(url);
        } else {
            if (settings.useInternalBrowser) {
                mainStack.push(Qt.resolvedUrl('./ui/InternalBrowserPage.qml'), {'url': url})
            } else {
                Qt.openUrlExternally(url)
            }
        }
    }

    function openRedditUrl(url) {
        console.log('Open URL: '+url);

        var singleCommentMatch = url.match(singleCommentUrlRegEx);
        if (singleCommentMatch) {
            console.log('Comment Thread match: '+singleCommentMatch[2]);
            var commentConn = qreddit.getCommentData(singleCommentMatch[2], singleCommentMatch[4]);
            commentConn .onSuccess.connect(function() {
                console.log('comment data: '+commentConn .response)
                var commentObj = new QReddit.CommentObj(qreddit, {'data': commentConn.response})
                console.log('commentObj: '+commentObj)
                mainStack.push(Qt.resolvedUrl("./ui/PostMessagePage.qml"), {'replyToObj': commentObj});
            })
            return;
        }

        var commentThreadMatch = url.match(commentThreadUrlRegEx);
        if (commentThreadMatch) {
            console.log('Comment Thread match: '+commentThreadMatch[2]);
            var postConn = qreddit.getPostData(commentThreadMatch[2]);
            postConn.onSuccess.connect(function() {
                console.log('post data: '+postConn.response)
                var postObj = new QReddit.PostObj(qreddit, {'data': postConn.response})
                console.log('postObj: '+postObj)
                console.log('postObj.data.title: '+postObj.data.title)
                mainStack.push(Qt.resolvedUrl("./ui/CommentsPage.qml"), {'postObj': postObj});
            })
            return;
        }

        var subredditThreadMatch = url.match(subredditThreadUrlRegEx);
        if (subredditThreadMatch) {
            console.log('Subreddit match: '+subredditThreadMatch[1]);
            mainStack.push(Qt.resolvedUrl("./ui/SubredditPage.qml"), {'subreddit': subredditThreadMatch[1]});
            return;
        }
    }

    // signal to open new URIs
    Connections {
        id: uriHandler
        target: UriHandler

        onOpened: {
            for (var i=0; i < uris.length; i++) {
                openRedditUrl(uris[i])
            }
        }
    }

}

