import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItems
import "../components"
import "../models/QReddit"
import "../models/QReddit/QReddit.js" as QReddit

Page {
    id: subredditpage

    property string subreddit: ""
    property string subredditFilter: "hot"

    title: subreddit === "" ? "Frontpage" : "/r/"+subreddit

    state: "default"

    head.sections {
        model: ["Hot", "New", "Top", "Controversial", "Rising"]
        onSelectedIndexChanged: {
            subredditFilter = head.sections.model[head.sections.selectedIndex].toLowerCase()
        }
    }

    states: [
        PageHeadState {
            name: "default"

            head: subredditpage.head
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

                    }
                },
                Action {
                    id: inboxUnreadAction
                    text: "New Unread"
                    iconSource: Qt.resolvedUrl("../images/email-unread.svg")
                    visible: uReadIt.qreddit.notifier.isLoggedIn && false
                    onTriggered: {

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
            head: subredditpage.head
            backAction: Action {
                id: cancelChangeAction
                text: "back"
                iconName: "close"
                onTriggered: {
                    subredditField.text = subreddit
                    subredditpage.state = "default"
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
                        subredditpage.state = "default"
                    }
                }
            ]
            contents: TextField {
                id: subredditField
                placeholderText: "Frontpage"
                width: parent.width - units.gu(2)
                text: subreddit
                visible : subredditpage.state == "change_subreddit"
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                onAccepted: confirmChangeAction.triggered(subredditField)
            }
        }
    ]

    MultiColumnListView {
        id: postsList
        anchors.fill: parent
        width: parent.width

        columns: parent.width > units.gu(40) ? parent.width / units.gu(40) : 1

        rowSpacing: units.gu(1)
        colSpacing: units.gu(1)

        balanced: true

        Connections {
            target: uReadIt.qreddit.notifier

            onActiveUserChanged: {
                postsList.clear();
                postsModel.clear();
                postsModel.load();
            }
        }

        model: SubredditListModel {
            id: postsModel
            redditObj: uReadIt.qreddit
            subreddit: subredditpage.subreddit
            filter: subredditpage.subredditFilter

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

        property real loadMoreLength: units.gu(10)
        property real overflow: 0
        property variant spaceRect: null

        Connections {
            target: postsList

            onContentYChanged: {
                var pf = postsList
                if(pf.atYEnd && !pf.atYBeginning && (pf.contentHeight >= parent.height)) {
                    moreLoaderItem.overflow = pf.contentY - pf.contentHeight + pf.height
                    if ((moreLoaderItem.overflow > moreLoaderItem.loadMoreLength) && !moreLoaderItem.spaceRect) {
                        moreLoaderItem.spaceRect = Qt.createQmlObject("import QtQuick 2.0; Item{width: 1; height: " + moreLoaderItem.loadMoreLength + "}", subredditpage)
                        postsModel.loadMore()
                    }

                } else {
                    moreLoaderItem.overflow = 0
                    moreLoaderItem.spaceRect = null
                }
            }
        }

    }

    onStateChanged: {
        if (state == "change_subreddit" && uReadIt.qreddit.notifier.isLoggedIn) {
            if (subscriptionsList.model == null ) {
                console.log('Updating subcription list')
                var updateConnObj = uReadIt.qreddit.updateSubscribedArray()
                updateConnObj.onSuccess.connect(function() {
                    subscriptionsList.model = uReadIt.qreddit.getSubscribedArray()
                })
            }
            subscriptionsPanel.open()
        } else {
            subscriptionsPanel.close()
        }
    }

    Panel {
        id: subscriptionsPanel
        anchors {
            left: parent.left
            bottom: parent.bottom
        }
        width: units.gu(30)
        height: parent.height

        align: Qt.AlignLeft
        animate: true

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: units.gu(10) // Account for the page header

            color: Qt.darker('#333333')

            ListView {
                id: subscriptionsList
                anchors.fill: parent

                model: null

                delegate: ListItems.Standard {
                    text: modelData
                    onClicked: {
                        postsList.clear();
                        subredditField.text = modelData
                        subreddit = modelData
                        subredditpage.state = "default"
                    }
                }
            }
            Scrollbar {
                flickableItem: subscriptionsList
                align: Qt.AlignTrailing
            }
        }
    }
}
