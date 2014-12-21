import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0
import Ubuntu.Web 0.2


Page {
    property var postObj

    title: postObj.data.title

    head.contents: Label {
        text: title
        height: parent.height
        width: parent.width
        verticalAlignment: Text.AlignVCenter

        color: "white"
        fontSize: "x-large"
        fontSizeMode: Text.Fit

        maximumLineCount: 3
        minimumPointSize: 8
        elide: Text.Right
        wrapMode: Text.WordWrap
    }

    head.actions: [
        Action {
            id: vieInBrowserAction
            text: "Open Page"
            iconName: "webbrowser-app-symbolic"
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

    Component.onCompleted : {
        articlewebview.url = postObj.data.url
    }
    WebView {
        id: articlewebview
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
                text: i18n.tr("Save image")
                enabled: articleWebView.contextualData.img.toString() != ""
                onTriggered: console.log(articleWebView.contextualData.img)
            }
        }
    }
    flickable: articlewebview
    ProgressBar {
        id: loadProgressBar
        anchors.bottom: articlewebview.top
        anchors.left: parent.left
        anchors.right: parent.right
        minimumValue: 0
        maximumValue: 100
        visible: false
        height: units.gu(2)
    }

}
