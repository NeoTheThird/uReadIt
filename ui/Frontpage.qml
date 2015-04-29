import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItems
import "../components"
import "../models/QReddit"
import "../models/QReddit/QReddit.js" as QReddit

Page {
    id: frontpage

    property string subreddit: ""
    property string subredditFilter: "hot"

    property alias autoLoad: postsModel.autoLoad

    property alias lastPageAfter: postsModel.startAfter

    title: subreddit === "" ? i18n.tr("Frontpage") : "/r/"+subreddit

    state: "default"
    focus: true

    Keys.onPressed: {
        if (event.key == Qt.Key_F5) { refresh(); return; }
        if (event.key == Qt.Key_Home) { postsList.contentY = 0; return; }

        if (event.key == Qt.Key_PageDown) {
            var nextY = postsList.contentY + postsList.height - units.gu(10);
            if (nextY + postsList.height > postsList.contentHeight) {
                //nextY = postsList.contentHeight - postsList.height + moreLoaderItem.height;
            }
            postsList.contentY = nextY
            return;
        }
        if (event.key == Qt.Key_PageUp) {
            var prevY = postsList.contentY - postsList.height + units.gu(10);
            if (prevY < 0) {
                prevY = 0;
            }
            postsList.contentY = prevY
            return;
        }

        if ((event.modifiers & Qt.ControlModifier) && (event.key == Qt.Key_S)) {
            frontpage.state = "change_subreddit"
            head.sections.selectedIndex = 0
            return;
        }

        if ((event.modifiers & Qt.ControlModifier) && (event.key == Qt.Key_D)) {
            frontpage.state = "change_subreddit"
            head.sections.selectedIndex = 1
            return;
        }

        if ((event.modifiers & Qt.ControlModifier) && (event.key == Qt.Key_F)) {
            frontpage.state = "change_subreddit"
            head.sections.selectedIndex = 2
            subredditField.forceActiveFocus();
            subredditField.selectAll();
            return;
        }

        if ((event.modifiers & Qt.ControlModifier) && (event.key == Qt.Key_M)) {
            if (uReadIt.qreddit.notifier.isLoggedIn && uReadIt.qreddit.notifier.hasUnreadMessages) {
                inboxUnreadAction.trigger()
            } else {
                inboxAction.trigger()
            }

            return;
        }

    }
    PageHeadSections {
        id: defaultStateSections
        model: [i18n.tr("Hot"), i18n.tr("New"), i18n.tr("Top"), i18n.tr("Controversial"), i18n.tr("Rising")]
        selectedIndex: 0
        onSelectedIndexChanged: {
            subredditFilter = head.sections.model[head.sections.selectedIndex].toLowerCase()
        }
    }

    PageHeadSections {
        id: changeSubredditStateSections
        model: [i18n.tr("Subscriptions"), i18n.tr("Defaults"), i18n.tr("Search")]
        selectedIndex: uReadIt.qreddit.notifier.isLoggedIn ? 0 : 1
        property var subreddit_sources: ["subreddits_mine subscriber", "subreddits_default", "subreddits_search"]
        onSelectedIndexChanged: {
            subredditsList.subredditSource = subreddit_sources[selectedIndex]
        }
    }

    head.sections {
        model: defaultStateSections.model
        selectedIndex: defaultStateSections.selectedIndex
        onSelectedIndexChanged: {
            if (frontpage.state === "default") {
                defaultStateSections.selectedIndex = head.sections.selectedIndex
            } else if (frontpage.state === "change_subreddit") {
                changeSubredditStateSections.selectedIndex = head.sections.selectedIndex
            }
        }
    }

    onStateChanged: {
        if (state === "default") {
            frontpage.head.sections.model = defaultStateSections.model
            frontpage.head.sections.selectedIndex = defaultStateSections.selectedIndex
        } else if (state === "change_subreddit") {
            frontpage.head.sections.model = changeSubredditStateSections.model
            frontpage.head.sections.selectedIndex = changeSubredditStateSections.selectedIndex
        }

        if (state == "change_subreddit") {
            if (subredditsList.subredditSource === "" || !uReadIt.qreddit.notifier.isLoggedIn) {
                subredditsList.subredditSource = uReadIt.qreddit.notifier.isLoggedIn ? "subreddits_mine subscriber" : "subreddits_default"
            }

            subscriptionsPanel.open();
            subredditsList.currentIndex = 0;
        } else {
            subscriptionsPanel.close()
        }
    }

    states: [
        PageHeadState {
            id: defaultPageState
            name: "default"

            head: frontpage.head

            contents: Label {
                LayoutMirroring.enabled: Qt.application.layoutDirection == Qt.RightToLeft
                visible: frontpage.state === "default"
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                font.weight: Font.Light
                fontSize: "x-large"
                //color: styledItem.config.foregroundColor
                elide: Text.ElideRight

                text: frontpage.title
                MouseArea {
                    anchors.left: parent.left
                    width: parent.contentWidth
                    height: parent.height

                    onClicked: {
                        postsList.contentY = 0;
                    }
                }
            }

            backAction: Action {
                id: subredditAction
                objectName: "changeSubredditAction"

                iconName: "navigation-menu"
                //iconSource: Qt.resolvedUrl("../images/subreddit-menu.svg")
                text: i18n.tr("Subreddit")
                onTriggered: {
                    state = "change_subreddit"
                }

            }
            actions: [
                Action {
                    id: loginAction
                    text: i18n.tr("Login")
                    iconName: "contact"
                    visible: !uReadIt.qreddit.notifier.isLoggedIn
                    onTriggered: {
                        mainStack.push(Qt.resolvedUrl("UserAccountsPage.qml"));
                    }
                },
                Action {
                    id: inboxAction
                    text: i18n.tr("Inbox")
                    iconName: "email"
                    visible: uReadIt.qreddit.notifier.isLoggedIn && !inboxUnreadAction.visible
                    onTriggered: {
                        mainStack.push(Qt.resolvedUrl("UserMessagesPage.qml"), {'where': 'inbox'});
                    }
                },
                Action {
                    id: inboxUnreadAction
                    text: i18n.tr("New Unread")
                    iconSource: Qt.resolvedUrl("../images/email-unread.svg")
                    visible: uReadIt.qreddit.notifier.isLoggedIn && uReadIt.qreddit.notifier.hasUnreadMessages
                    onTriggered: {
                        mainStack.push(Qt.resolvedUrl("UserMessagesPage.qml"), {'where': 'unread'});
                    }
                },
                Action {
                    id: userAction
                    text: i18n.tr("Users")
                    iconName: "contact"
                    visible: uReadIt.qreddit.notifier.isLoggedIn
                    onTriggered: {
                        mainStack.push(Qt.resolvedUrl("UserAccountsPage.qml"));
                    }
                },
                Action {
                    id: settingsAction
                    text: i18n.tr("Settings")
                    iconName: "settings"
                    onTriggered: {
                        mainStack.push(Qt.resolvedUrl("SettingsPage.qml"));
                    }
                },
                Action {
                    id: aboutAction
                    text: i18n.tr("About")
                    iconName: "help"
                    onTriggered: {
                        mainStack.push(Qt.resolvedUrl("AboutPage.qml"));
                    }
                },
                Action {
                    id: logoutAction
                    text: i18n.tr("Logout")
                    iconName: "system-log-out"
                    visible: uReadIt.qreddit.notifier.isLoggedIn
                    onTriggered: {
                        var logoutConnObj = uReadIt.qreddit.logout();
                        logoutConnObj.onSuccess.connect(function() {
                            //postsModel.clear();
                            //postsModel.load();
                        });
                    }
                }
            ]
        },
        PageHeadState {
            id: changeState
            name: "change_subreddit"
            head: frontpage.head
            backAction: Action {
                id: cancelChangeAction
                text: i18n.tr("Back")
                iconName: "close"
                onTriggered: {
                    subredditField.text = subreddit
                    frontpage.state = "default"
                }
            }
            actions: [
                Action {
                    id: confirmChangeAction
                    text: i18n.tr("Confirm")
                    iconName: "ok"
                    onTriggered: {
                        postsList.clear();
                        subreddit = subredditField.text
                        frontpage.state = "default"
                    }
                }
            ]
            contents: TextField {
                id: subredditField
                placeholderText: i18n.tr("Frontpage")
                width: parent.width - units.gu(2)
                text: subreddit
                visible : frontpage.state === "change_subreddit"
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                onAccepted: confirmChangeAction.triggered(subredditField)
                onTextChanged: {
                    subredditsList.subredditSearch = text;
                }
                Keys.onPressed: { if (event.key == Qt.Key_Escape) frontpage.state = "default"; }
            }
        }
    ]

    Connections {
        target: uReadIt.qreddit.notifier

        onIsLoggedInChanged: {
            if (postsModel.loaded) {
                reload()
            }
            changeSubredditStateSections.selectedIndex = uReadIt.qreddit.notifier.isLoggedIn ? 0 : 1
        }

    }

    function reload() {
        postsList.clear();
        postsModel.clear();
        postsModel.load();
    }

    function refresh() {
        postsModel.startAfter = "";
        reload();
    }

    PullToRefresh {
        refreshing: postsList.isLoading
        onRefresh: frontpage.refresh()
        target: postsList
    }
    MultiColumnListView {
        id: postsList
        anchors.fill: parent
        anchors.margins: units.gu(1)
        width: parent.width

        columns: parent.width > units.gu(50) ? parent.width / units.gu(50) : 1

        rowSpacing: units.gu(1)
        colSpacing: units.gu(1)

        balanced: true

        Behavior on contentY {
                SmoothedAnimation { duration: 500 }
        }

        model: SubredditListModel {
            id: postsModel
            redditObj: uReadIt.qreddit
            subreddit: frontpage.subreddit
            filter: frontpage.subredditFilter

        }

        delegate: PostListItem {
            title: model.data.title
            thumbnail: (model.data.thumbnail != null && model.data.thumbnail != "self") ? model.data.thumbnail : ""
            author: "/r/"+model.data.subreddit
            domain: model.data.domain
            text: model.data.selftext
            score: model.data.score
            url: model.data.url
            comments: model.data.num_comments
            likes: model.data.likes
            property var postObj: new QReddit.PostObj(uReadIt.qreddit, model);

            onClicked: {
                if (model.data.is_self) {
                    mainStack.push(Qt.resolvedUrl("CommentsPage.qml"), {'postObj': model})
                } else {
                    mainStack.push(Qt.resolvedUrl("ArticlePage.qml"), {'postObj': model})
                }
            }
            onUpvoteClicked: {
                if (!uReadIt.qreddit.notifier.isLoggedIn) {
                    console.log("You can't vote when you're not logged in!");
                    return;
                }

                var voteConnObj = postObj.upvote();
                var postItem = this;
                voteConnObj.onSuccess.connect(function(response){
                    postItem.likes = model.data.likes = postObj.data.likes;
                    postItem.score = model.data.score = postObj.data.score;
                });
            }
            onDownvoteClicked: {
                if (!uReadIt.qreddit.notifier.isLoggedIn) {
                    console.log("You can't vote when you're not logged in!");
                    return;
                }
                var voteConnObj = postObj.downvote();
                var postItem = this;
                voteConnObj.onSuccess.connect(function(response){
                    postItem.likes = model.data.likes = postObj.data.likes;
                    postItem.score = model.data.score = postObj.data.score;
                });
            }
            onCommentsClicked: mainStack.push(Qt.resolvedUrl("CommentsPage.qml"), {'postObj': model})
        }

    }

    // TODO: refactor this
    Item {
        id: moreLoaderItem
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        height: units.gu(2)

        property real loadMoreLength: units.gu(0)
        property real overflow: 0
        property variant spaceRect: null

        Connections {
            target: postsList

            onAtYEndChanged: {
                var pf = postsList
                if(pf.atYEnd && !pf.atYBeginning && (pf.contentHeight >= parent.height)) {
                    moreLoaderItem.overflow = pf.contentY - pf.contentHeight + pf.height
                    if ((moreLoaderItem.overflow > moreLoaderItem.loadMoreLength) && !moreLoaderItem.spaceRect) {
                        moreLoaderItem.spaceRect = Qt.createQmlObject("import QtQuick 2.0; Item{width: 1; height: " + moreLoaderItem.loadMoreLength + "}", frontpage)
                        postsModel.loadMore()
                    }

                } else {
                    moreLoaderItem.overflow = 0
                    moreLoaderItem.spaceRect = null
                }
            }
        }

    }


    Panel {
        id: subscriptionsPanel
        property int sectionIndex: 0
        anchors {
            left: parent.left
            bottom: parent.bottom
        }
        width: parent.width
        height: parent.height

        align: Qt.AlignLeft
        animate: true
        visible: opened || animating

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(uReadIt.currentTheme.panelOverlay.r, uReadIt.currentTheme.panelOverlay.g, uReadIt.currentTheme.panelOverlay.b, 0.8)
            visible: !subscriptionsPanel.animating

            MouseArea {
                anchors.fill: parent
            }

        }

        Rectangle {
            width: units.gu(30)
            height: parent.height
            anchors.topMargin: units.gu(10) // Account for the page header

            color: uReadIt.currentTheme.panelColor
            Keys.onPressed: { if (event.key == Qt.Key_Escape) frontpage.state = "default"; }

            UbuntuListView {
                id: subredditsList
                anchors.fill: parent
                property string subredditSource: ""
                property string subredditSearch: subredditField.text

                model: ListModel {
                    id: subredditsModel
                }
                onSubredditSourceChanged: {
                    subredditsModel.clear()
                    if (subredditsList.subredditSource == "subreddits_search") {
                        subredditsModel.append({'data': {'display_name': subredditsList.subredditSearch, 'title': subredditsList.subredditSearch}})
                        var subsrConnObj = uReadIt.qreddit.getAPIConnection(subredditsList.subredditSource, {q: subredditsList.subredditSearch});
                        subsrConnObj.onConnection.connect(function(response){
                            for (var index in response.data.children){
                                subredditsModel.append(response.data.children[index])
                            }
                        });
                    } else {
                        if (subredditsList.subredditSource == "subreddits_mine subscriber") {
                            subredditsModel.append({'data': {'display_name': '', 'title': i18n.tr("Frontpage")}})
                        } else {
                            subredditsModel.append({'data': {'display_name': 'All', 'title': i18n.tr("All")}})
                        }

                        var subsrConnObj = uReadIt.qreddit.getAPIConnection(subredditsList.subredditSource);
                        subsrConnObj.onConnection.connect(function(response){
                            for (var index in response.data.children){
                                subredditsModel.append(response.data.children[index])
                            }
                        });
                    }
                }
                onSubredditSearchChanged: {
                    if (subredditsList.subredditSource == "subreddits_search") {
                        subredditsModel.clear()
                        subredditsModel.append({'data': {'display_name': subredditsList.subredditSearch, 'title': subredditsList.subredditSearch}})
                        subredditsList.currentIndex = 0
                        var subsrConnObj = uReadIt.qreddit.getAPIConnection(subredditsList.subredditSource, {q: subredditsList.subredditSearch});
                        subsrConnObj.onConnection.connect(function(response){
                            for (var index in response.data.children){
                                subredditsModel.append(response.data.children[index])
                            }
                        });
                    }
                }

                delegate: ListItems.Standard {
                    text: model.data['display_name'] === "" ? model.data['title'] : model.data['display_name']
                    property string subreddit_name: model.data['display_name']
                    selected: this.focus
                    progression: this.focus
                    onClicked: {
                        subredditField.text = subredditsList.subredditSource == "subreddits_search" ? subredditsList.subredditSearch : this.subreddit_name
                        subreddit = this.subreddit_name
                        frontpage.state = "default"
                    }
                }
            }
            Scrollbar {
                flickableItem: subredditsList
                //align: Qt.AlignTrailing
            }
        }
    }

    flickable: uReadIt.height < units.gu(70) ? postsList : null
    clip: uReadIt.height < units.gu(70) ? false : true

    ActivityIndicator {
        id: loadingIndicator
        anchors.centerIn: parent
        running: postsModel.loading
    }
}
