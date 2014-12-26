import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0
import "../components"
import "../models/QReddit"

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
                    id: messagesAction
                    text: "messages"
                    iconName: "email"
                    onTriggered: {

                    }
                },
                Action {
                    id: settingsAction
                    text: "settings"
                    iconName: "settings"
                    onTriggered: {

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

        model: SubredditListModel {
            id: postsModel
            subreddit: subredditpage.subreddit
            filter: subredditpage.subredditFilter

        }

        delegate: PostListItem {
            title: model.data.title
            thumbnail: (model.data.thumbnail != null && model.data.thumbnail != "self") ? model.data.thumbnail : ""
            author: model.data.author
            domain: model.data.domain
            text: model.data.selftext
            score: model.data.score
            url: model.data.url
            comments: model.data.num_comments


            onClicked: {
                if (model.data.is_self) {
                    mainStack.push(Qt.resolvedUrl("CommentsPage.qml"), {'postObj': model})
                } else {
                    mainStack.push(Qt.resolvedUrl("ArticlePage.qml"), {'postObj': model})
                }
            }
            onUpvoteClicked: console.log('item upvoted')
            onDownvoteClicked: console.log('item downvoted')
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
}
