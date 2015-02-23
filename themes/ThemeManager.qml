import QtQuick 2.0
import Ubuntu.Components 1.1

QtObject {
    id: themeManager
    property string name
    property var themeObject: new QtObject();

    onNameChanged: {
        var themeComponent = Qt.createComponent(Qt.resolvedUrl(name))
        if (themeComponent.status == Component.Ready) {
            var themeObject = themeComponent.createObject(themeManager)
            console.log("Theme background: "+themeObject.backgroundColor)
            for (var key in themeObject) {
                if (themeManager.hasOwnProperty(key)) {
                    themeManager[key] = themeObject[key]
                }
            }
        }
    }

    // MainView
    property color backgroundColor
    property color panelColor

    // Base Text
    property color baseFontColor
    property color baseLinkColor

    // Posts
    property color postItemBackgroundColor
    property color postItemBorderColor
    property color postItemHeaderColor
    property color postItemFontColor

    // Comments
    property color commentBackgroundColorEven: Qt.darker(backgroundColor, 1.2)
    property color commentBackgroundColorOdd: Qt.darker(backgroundColor, 1.5)
    property color commentFontColor: baseFontColor
    property color commentLinkColor: baseLinkColor

    // Messages
    property color messageBackgroundColor: commentBackgroundColorOdd
    property color messageFontColor: baseFontColor
    property color messageLinkColor: baseLinkColor

    // Sharing
    property color shareBackgroundColor: Qt.lighter(backgroundColor)
}

