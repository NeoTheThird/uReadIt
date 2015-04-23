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

    head.contents: Label {
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

        text: subredditpage.title
        MouseArea {
            width: parent.width
            height: parent.height

            onClicked: {
                postsList.contentY = frontpage.header.height * -1
            }
        }
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

        property real loadMoreLength: units.gu(0)
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
    flickable: uReadIt.height < units.gu(70) ? postsList : null
    clip: true

}
