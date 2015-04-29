import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0
import Ubuntu.Web 0.2
import Ubuntu.Content 0.1
import Ubuntu.DownloadManager 0.1
import "../components"

Page {
    id: articlePage
    property var postObj

    title: postObj.data.title

    head.contents: Label {
        text: title
        height: parent.height
        width: parent.width
        verticalAlignment: Text.AlignVCenter

        fontSize: "x-large"
        fontSizeMode: Text.Fit

        maximumLineCount: 3
        minimumPointSize: 8
        elide: Text.Right
        wrapMode: Text.WordWrap
    }

    head.actions: [
        Action {
            id: shareAction
            text: "Share"
            iconName: "share"
            onTriggered: {
                mainStack.push(Qt.resolvedUrl("ShareLinkPage.qml"), {'link': postObj.data.url, 'contentType': ContentType.Links})
            }
        },
        Action {
            id: viewInBrowserAction
            text: "Open Page"
            iconName: "external-link"
            onTriggered: {
                Qt.openUrlExternally(postObj.data.url)
            }
        },
        Action {
            id: viewCommentsAction
            text: "Comments"
            iconName: "message"
            onTriggered: {
                mainStack.push(Qt.resolvedUrl("CommentsPage.qml"), {'postObj': postObj})
            }
        }
    ]
    state: 'default'
    Component.onCompleted : {
        articleWebView.url = postObj.data.url
        articlePage.header.animate=false
        articlePage.header.show();
        articlePage.header.animate=true
    }

    WebView {
        id: articleWebView
        anchors.fill: parent
        incognito: true

        onLoadingChanged: {
            loadProgressBar.visible = loading
        }

        onLoadProgressChanged: {
            loadProgressBar.value = loadProgress
        }

        contextualActions: ActionList {
            Action {
                text: i18n.tr("Open link in browser")
                enabled: articleWebView.contextualData.href.toString() != ""
                onTriggered: Qt.openUrlExternally(articleWebView.contextualData.href)
            }
            Action {
                text: i18n.tr("Open image in browser")
                enabled: articleWebView.contextualData.img.toString() != ""
                onTriggered: Qt.openUrlExternally(articleWebView.contextualData.img)
            }
            Action {
                text: i18n.tr("Share image link")
                enabled: articleWebView.contextualData.img.toString() != ""
                onTriggered: mainStack.push(Qt.resolvedUrl("ShareLinkPage.qml"), {'link': articleWebView.contextualData.img, 'contentType': ContentType.Pictures})
            }
            Action {
                text: i18n.tr("Share image")
                enabled: articleWebView.contextualData.img.toString() != ""
                onTriggered: {
                    console.log('Downloading image: '+articleWebView.contextualData.img)
                    imageDownloader.download(articleWebView.contextualData.img)
                }
            }
        }
    }

    ProgressBar {
        id: loadProgressBar
        anchors.top: articleWebView.top
        anchors.left: parent.left
        anchors.right: parent.right
        minimumValue: 0
        maximumValue: 100
        visible: false
        height: units.gu(0.5)
        showProgressPercentage: false
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
