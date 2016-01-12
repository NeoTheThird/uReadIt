import QtQuick 2.4
import QtQuick.XmlListModel 2.0
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.0 as ListItems
import Ubuntu.Content 1.1
import Ubuntu.DownloadManager 0.1
import "../components"
import "../models/QReddit"
import "../models/QReddit/QReddit.js" as QReddit

Page {
    id: gallerypage

    property int currentPage: 1
    property string subreddit: ""
    property string subredditFilter: "hot"

    property string url

    title: subreddit === "" ? "Frontpage" : "/r/"+subreddit

    state: "default"

    head.actions: [
        Action {
            id: shareAction
            text: "Share"
            iconName: "share"
            onTriggered: {
                imageDownloader.download(imagesView.currentItem.sourceUrl)
            }
        },
        Action {
            id: viewInBrowserAction
            text: "Open Page"
            iconName: "external-link"
            onTriggered: {
                Qt.openUrlExternally(imagesView.currentItem.sourceUrl)
            }
        },
        Action {
            id: viewCommentsAction
            text: "Comments"
            iconName: "message"
            onTriggered: {
                mainStack.push(Qt.resolvedUrl("CommentsPage.qml"), {'postObj': imagesView.currentItem.postObj})
            }
        }
    ]

    head.contents: Label {
        LayoutMirroring.enabled: Qt.application.layoutDirection == Qt.RightToLeft
        height: parent.height
        width: parent.width
        verticalAlignment: Text.AlignVCenter

        fontSize: "x-large"
        fontSizeMode: Text.Fit

        maximumLineCount: 4
        minimumPointSize: 8
        elide: Text.Right
        wrapMode: Text.WordWrap

        text: gallerypage.title
    }

    ListView {
        anchors.fill: parent
        id: imagesView;
        model: ImagesListModel {
            id: postsModel
            redditObj: uReadIt.qreddit
            subreddit: gallerypage.subreddit
            filter: gallerypage.subredditFilter

        }

        orientation: Qt.Horizontal;
        snapMode: ListView.SnapOneItem
        highlightRangeMode: ListView.StrictlyEnforceRange
        boundsBehavior: Flickable.StopAtBounds
        cacheBuffer: width

        onCurrentItemChanged: {
            gallerypage.title = currentItem.title
            gallerypage.url = currentItem.sourceUrl
        }

        interactive: currentItem ? !currentItem.isInteractive : true
        onInteractiveChanged: console.log('ListView.interactive: '+interactive)

        delegate: GalleryImage {
            id: image
            width: gallerypage.width
            height: gallerypage.height
            title: model.data.title
            sourceUrl: model.data.url
            thumbnailUrl: model.data.thumbnail
            property var postObj: model
        }



        footer: Rectangle {
            height: parent.height
            width: units.gu(1)
            visible: true
            opacity: 0
            ActivityIndicator {
                running: parent.visible
            }
        }

    }

    Connections {
        target: imagesView

        onContentXChanged: {
            if(imagesView.atXEnd && !imagesView.atXBeginning && (imagesView.contentWidth >= parent.width)) {
                if (imagesView.footerItem.visible) {
                    console.log("Loading more...")
                    imagesView.footerItem.visible = false
                    postsModel.loadMore()
                }
            } else {
                imagesView.footerItem.visible = true
            }
        }
    }

    flickable: null
    clip: true

    ProgressBar {
        id: loadProgressBar
        anchors.top: imagesView.top
        anchors.left: parent.left
        anchors.right: parent.right
        minimumValue: 0
        maximumValue: 1
        visible: imagesView.currentItem.imageStatus != Image.Ready
        height: units.gu(0.5)
        showProgressPercentage: false
        value: imagesView.currentItem.progress
    }
    SingleDownload {
        id: imageDownloader
        autoStart: true

        onFinished: {
            console.log('Downloaded to: '+path)
            mainStack.push(Qt.resolvedUrl("ShareImagePage.qml"), {'link': path, 'contentType': ContentType.Pictures})
        }
    }
}
