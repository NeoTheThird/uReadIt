import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0
import "../components"
import "../models/QReddit/QReddit.js" as QReddit

Page {

    property string subreddit: ""
    property var redditObj: new QReddit.QReddit("Karma Machine Reddit App 0.78", "karma-machine")
    property var frontpageObj: redditObj.getSubredditObj(subreddit)

    title: subreddit === "" ? "Frontpage" : subreddit

    head {
        sections {
            model: width > units.gu(50) ? ["Hot", "New", "Rising", "Top", "Controversial", "Gilded"] : ["Hot", "New", "Rising", "Top"]
        }
        backAction: Action {
            id: subredditAction
            objectName: "changeSubredditAction"

            iconName: "navigation-menu"
            //iconSource: Qt.resolvedUrl("../images/subreddit-menu.svg")
            text: i18n.tr("Subreddit")

        }
    }

    MultiColumnListView {
        id: postsList
        anchors.fill: parent

        columns: parent.width > units.gu(40) ? parent.width / units.gu(40) : 1

        rowSpacing: units.gu(1)
        colSpacing: units.gu(1)
        model: ListModel {
            id: postsModel
        }

        Component.onCompleted: {
            var connObj = frontpageObj.getPostsListing('hot', {})
            connObj.onSuccess.connect(function(response) {
                console.log("Connection Succeeded")
                console.log(connObj.response)
                for (var i = 0; i < connObj.response.length; i++) {
                    var postObj = connObj.response[i];
                    //console.log("Post: "+postObj);
                    postsModel.append(postObj);
                }

                loadItems();
            });
        }

        delegate: PostListItem {
            title: model.data.title
            thumbnail: model.data.thumbnail != "self" ? model.data.thumbnail : null
            author: model.data.author
            domain: model.data.domain
            text: model.data.selftext
            score: model.data.score
        }
    }
}
