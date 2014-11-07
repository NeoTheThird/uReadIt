import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0
import "../components"
import "../models/QReddit/QReddit.js" as QReddit

Page {

    property var redditObj: new QReddit.QReddit("Karma Machine Reddit App 0.78", "karma-machine")
    property var frontpageObj: redditObj.getSubredditObj("linux")

    title: "Frontpage"

    head {
        sections {
            model: ["Hot", "New", "Rising", "Controversial", "Top", "Gilded"]
        }
    }

    MultiColumnListView {
        id: postsList
        anchors.fill: parent

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
            thumbnail: model.data.thumbnail
            author: model.data.author
            domain: model.data.domain
            text: model.data.selftext
            score: model.data.score
            Component.onCompleted: {
                for(var k in model) {
                    console.log('model['+k+']: '+data[k])
                }
            }
        }
    }
    flickable: postsList.flickable
}
