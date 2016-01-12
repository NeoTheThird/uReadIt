import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.0 as ListItems
import "../components"
import "../models/QReddit"
import "../models/QReddit/QReddit.js" as QReddit

Page {
    id: subredditSwitcherPage

    title: "Frontpage"
    property var subreddit_sources: ["subreddits_default", "subreddits_search", "subreddits_mine subscriber"]
    head.sections {
        model: uReadIt.qreddit.notifier.isLoggedIn ? ["Defaults", "Search", "My Subscriptions"] : ["Defaults", "Search"]
        selectedIndex: uReadIt.qreddit.notifier.isLoggedIn ? 2 : 0
        onSelectedIndexChanged: {
            //subredditsList.subredditSource = subreddit_sources[selectedIndex]
        }
    }

    state: "change_subreddit"
    states: [
        PageHeadState {
            id: changeState
            name: "change_subreddit"
            head: subredditSwitcherPage.head
            backAction: Action {
                id: cancelChangeAction
                text: "back"
                iconName: "close"
                onTriggered: {
                    subredditField.text = subreddit
                    mainStack.pop()
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
                        mainStack.pop()
                    }
                }
            ]
            contents: TextField {
                id: subredditField
                placeholderText: "Frontpage"
                width: parent.width - units.gu(2)
                text: subreddit
                visible : true
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                onAccepted: confirmChangeAction.triggered(subredditField)
                onTextChanged: {
                    subredditsList.subredditSearch = text;
                }
            }
        }
    ]

    UbuntuListView {
        id: subredditsList
        anchors.fill: parent
        property string subredditSource: ""
        property string subredditSearch: subredditField.text

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
                subredditField.text = modelData.data['display_name']
                subreddit = modelData.data['display_name']
                frontpage.state = "default"
            }
        }
    }
    Scrollbar {
        flickableItem: subredditsList
        align: Qt.AlignTrailing
    }

    flickable: subredditsList

}
