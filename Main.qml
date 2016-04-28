import QtQuick 2.4
import Ubuntu.Components 1.3
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
    applicationName: "com.ubuntu.developer.mhall119.ureadit"
    //applicationName: "com.ubuntu.developer.mhall119.ureadit-dev"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    automaticOrientation: true

    // Make room for the keyboard
    anchorToKeyboard: true

    width: units.gu(100)
    height: units.gu(75)

    Themes.ThemeManager {
        id: themeManager
        themes: [
            {name: i18n.tr('uReadIt (Dark)'),   source: Qt.resolvedUrl('themes/RedditDark.qml')},
            {name: i18n.tr('Ambiance (Light)'), source: Qt.resolvedUrl('themes/Ambiance.qml')},
            {name: i18n.tr('Reddit (Blue)'),    source: Qt.resolvedUrl('themes/RedditLight.qml')}
        ]
        source: settings.themeName
    }
    property alias currentTheme: themeManager.theme
    property var themeManager: themeManager

    headerColor: currentTheme.backgroundHeaderColor
    backgroundColor: currentTheme.backgroundColor
    footerColor: currentTheme.backgroundFooterColor
    theme.name: currentTheme.baseThemeName

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
                mainStack.push(frontpage);
                frontpage.reload();
                if (args.values.url) {
                    openRedditUrl(args.values.url)
                }
            })
        } else {
            mainStack.push(frontpage);
            frontpage.reload();
            if (args.values.url) {
                openRedditUrl(args.values.url)
            }
        }
    }

    PageStack {
        id: mainStack
        anchors {
                 fill: parent
                 topMargin: units.gu(10)
                }

        Keys.onPressed: { if (mainStack.depth > 1 && event.key == Qt.Key_Escape) pop(); }
        onCurrentPageChanged: {
            currentPage.forceActiveFocus();
        }
    }

    Frontpage {
        id: frontpage
        subreddit: ''
        StateSaver.properties: "subreddit, lastPageAfter"
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
            help: i18n.tr("Link to a Reddit thread")
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

        var singleCommentMatch = url.match(singleCommentUrlRegEx);
        if (singleCommentMatch) {
            var commentConn = qreddit.getCommentData(singleCommentMatch[2], singleCommentMatch[4]);
            commentConn .onSuccess.connect(function() {
                var commentObj = new QReddit.CommentObj(qreddit, {'data': commentConn.response})
                mainStack.push(Qt.resolvedUrl("./ui/PostMessagePage.qml"), {'replyToObj': commentObj});
            })
            return;
        }

        var commentThreadMatch = url.match(commentThreadUrlRegEx);
        if (commentThreadMatch) {
            var postConn = qreddit.getPostData(commentThreadMatch[2]);
            postConn.onSuccess.connect(function() {
                var postObj = new QReddit.PostObj(qreddit, {'data': postConn.response})
                mainStack.push(Qt.resolvedUrl("./ui/CommentsPage.qml"), {'postObj': postObj});
            })
            return;
        }

        var subredditThreadMatch = url.match(subredditThreadUrlRegEx);
        if (subredditThreadMatch) {
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

