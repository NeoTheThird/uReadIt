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

    title: subreddit === "" ? "Frontpage" : "/r/"+subreddit

    state: "default"

    PageHeadSections {
        id: defaultStateSections
        model: ["Hot", "New", "Top", "Controversial", "Rising"]
        selectedIndex: 0
        onSelectedIndexChanged: {
            subredditFilter = head.sections.model[head.sections.selectedIndex].toLowerCase()
        }
    }

    PageHeadSections {
        id: changeSubredditStateSections
        model: uReadIt.qreddit.notifier.isLoggedIn ? ["Defaults", "Search", "My Subscriptions"] : ["Defaults", "Search"]
        selectedIndex: uReadIt.qreddit.notifier.isLoggedIn ? 2 : 0
        property var subreddit_sources: ["subreddits_default", "subreddits_search", "subreddits_mine subscriber"]
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

            subscriptionsPanel.open()
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
                    width: parent.width
                    height: parent.height

                    onClicked: {
                        postsList.contentY = frontpage.header.height * -1
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
                    text: "Login"
                    iconName: "contact"
                    visible: !uReadIt.qreddit.notifier.isLoggedIn
                    onTriggered: {
                        mainStack.push(Qt.resolvedUrl("UserAccountsPage.qml"));
                    }
                },
                Action {
                    id: inboxAction
                    text: "Inbox"
                    iconName: "email"
                    visible: uReadIt.qreddit.notifier.isLoggedIn && !inboxUnreadAction.visible
                    onTriggered: {
                        mainStack.push(Qt.resolvedUrl("UserMessagesPage.qml"), {'where': 'inbox'});
                    }
                },
                Action {
                    id: inboxUnreadAction
                    text: "New Unread"
                    iconSource: Qt.resolvedUrl("../images/email-unread.svg")
                    visible: uReadIt.qreddit.notifier.isLoggedIn && uReadIt.qreddit.notifier.hasUnreadMessages
                    onTriggered: {
                        mainStack.push(Qt.resolvedUrl("UserMessagesPage.qml"), {'where': 'unread'});
                    }
                },
                Action {
                    id: userAction
                    text: "Users"
                    iconName: "contact"
                    visible: uReadIt.qreddit.notifier.isLoggedIn
                    onTriggered: {
                        mainStack.push(Qt.resolvedUrl("UserAccountsPage.qml"));
                    }
                },
                Action {
                    id: settingsAction
                    text: "Settings"
                    iconName: "settings"
                    onTriggered: {
                        mainStack.push(Qt.resolvedUrl("SettingsPage.qml"));
                    }
                },
                Action {
                    id: logoutAction
                    text: "Logout"
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
//            sections {
//                model: ["My Subscriptions", "Defaults", "All"]
//                selectedIndex: 0
//                onSelectedIndexChanged: {
//                    console.log("Change subreddit list to: "+selectedIndex)
//                }
//            }
            backAction: Action {
                id: cancelChangeAction
                text: "back"
                iconName: "close"
                onTriggered: {
                    subredditField.text = subreddit
                    frontpage.state = "default"
                }
            }
            actions: [
                Action {
                    id: confirmChangeAction
                    text: "confirm"
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
                placeholderText: "Frontpage"
                width: parent.width - units.gu(2)
                text: subreddit
                visible : frontpage.state === "change_subreddit"
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                onAccepted: confirmChangeAction.triggered(subredditField)
                onTextChanged: {
                    subredditsList.subredditSearch = text;
                }
            }
        }
    ]

    Connections {
        target: uReadIt.qreddit.notifier

        onIsLoggedInChanged: {
            if (postsModel.loaded) {
                reload()
            }
            changeSubredditStateSections.selectedIndex = uReadIt.qreddit.notifier.isLoggedIn ? 2 : 0
        }

    }

    function reload() {
        postsList.clear();
        postsModel.clear();
        postsModel.load();
    }

    function refresh() {
        console.log("resetting postsModel")
        postsModel.startAfter = "";
        reload();
    }

    PullToRefresh {
        anchors.horizontalCenter: parent.horizontalCenter
        refreshing: postsList.isLoading
        onRefresh: frontpage.refresh()
        target: postsList
    }
    MultiColumnListView {
        id: postsList
        anchors.fill: parent
        anchors.margins: units.gu(1)
        width: parent.width

        columns: parent.width > units.gu(40) ? parent.width / units.gu(40) : 1

        rowSpacing: units.gu(1)
        colSpacing: units.gu(1)

        balanced: true

        Behavior on contentY {
                SmoothedAnimation { velocity: 25000 }
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
            color: Qt.rgba(uReadIt.theme.panelOverlay.r, uReadIt.theme.panelOverlay.g, uReadIt.theme.panelOverlay.b, 0.8)
            visible: !subscriptionsPanel.animating

            MouseArea {
                anchors.fill: parent
            }

        }

        Rectangle {
            width: units.gu(30)
            height: parent.height
            anchors.topMargin: units.gu(10) // Account for the page header

            color: uReadIt.theme.panelColor

            UbuntuListView {
                id: subredditsList
                anchors.fill: parent
                property string subredditSource: ""
                property string subredditSearch: subredditField.text

                header: ListItems.Standard {
                    text: subredditsList.subredditSource == "subreddits_search" ? subredditsList.subredditSearch : (subredditsList.subredditSource == "subreddits_mine subscriber" ? "Frontpage" : "All")
                    onClicked: {
                        postsList.clear();
                        subredditField.text = subredditsList.subredditSource == "subreddits_search" ? subredditsList.subredditSearch : (subredditsList.subredditSource == "subreddits_mine subscriber" ? "" : "All")
                        subreddit = subredditsList.subredditSource == "subreddits_search" ? subredditsList.subredditSearch : (subredditsList.subredditSource == "subreddits_mine subscriber" ? "" : "All")
                        frontpage.state = "default"
                    }
                }

                model: null
                onSubredditSourceChanged: {
                    subredditsList.model = null
                    if (subredditsList.subredditSource == "subreddits_search") {
                        var subsrConnObj = uReadIt.qreddit.getAPIConnection(subredditsList.subredditSource, {q: subredditsList.subredditSearch});
                        subsrConnObj.onConnection.connect(function(response){
                            subredditsList.model = response.data.children
                        });
                    } else {
                        var subsrConnObj = uReadIt.qreddit.getAPIConnection(subredditsList.subredditSource);
                        subsrConnObj.onConnection.connect(function(response){
                            subredditsList.model = response.data.children
                        });
                    }
                }
                onSubredditSearchChanged: {
                    if (subredditsList.subredditSource == "subreddits_search") {
                        var subsrConnObj = uReadIt.qreddit.getAPIConnection(subredditsList.subredditSource, {q: subredditsList.subredditSearch});
                        subsrConnObj.onConnection.connect(function(response){
                            subredditsList.model = response.data.children
                        });
                    }
                }

                delegate: ListItems.Standard {
                    text: modelData.data['display_name']
                    onClicked: {
                        postsList.clear();
                        subredditField.text = subredditsList.subredditSource == "subreddits_search" ? subredditsList.subredditSearch : modelData.data['display_name']
                        subreddit = modelData.data['display_name']
                        frontpage.state = "default"
                    }
                }
            }
            Scrollbar {
                flickableItem: subredditsList
                align: Qt.AlignTrailing
            }
        }
    }

    flickable: subscriptionsPanel.visible ? subredditsList : postsList

}
