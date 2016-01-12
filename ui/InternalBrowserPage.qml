import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.0
import Ubuntu.Web 0.2
import Ubuntu.Content 1.1
import "../components"

Page {
    id: browserPage

    property string url
    title: browserWebView.title || url

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
                mainStack.push(Qt.resolvedUrl("ShareLinkPage.qml"), {'link': url, 'contentType': ContentType.Links})
            }
        },
        Action {
            id: viewInBrowserAction
            text: "Open Page"
            iconName: "external-link"
            onTriggered: {
                Qt.openUrlExternally(url)
            }
        }
    ]
    state: 'default'
    Component.onCompleted : {
        browserWebView.url = url
        browserPage.header.animate=false
        browserPage.header.show();
        browserPage.header.animate=true
    }

    WebView {
        id: browserWebView
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
                enabled: browserWebView.contextualData.href.toString() != ""
                onTriggered: Qt.openUrlExternally(browserWebView.contextualData.href)
            }
            Action {
                text: i18n.tr("Open image in browser")
                enabled: browserWebView.contextualData.img.toString() != ""
                onTriggered: Qt.openUrlExternally(browserWebView.contextualData.img)
            }
            Action {
                text: i18n.tr("Share image")
                enabled: browserWebView.contextualData.img.toString() != ""
                onTriggered: mainStack.push(Qt.resolvedUrl("ShareLinkPage.qml"), {'link': browserWebView.contextualData.img, 'contentType': ContentType.Pictures})
            }
        }
    }

    ProgressBar {
        id: loadProgressBar
        anchors.bottom: browserWebView.top
        anchors.left: parent.left
        anchors.right: parent.right
        minimumValue: 0
        maximumValue: 100
        visible: false
        height: units.gu(2)
    }


}
