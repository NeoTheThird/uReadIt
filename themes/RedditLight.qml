import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes.Ambiance 0.1

QtObject {
    property string baseThemeName: "Ubuntu.Components.Themes.Ambiance"

    // MainView
    property color backgroundColor: '#EDEDED'
    property color backgroundHeaderColor: '#cee3f8'
    property color backgroundFooterColor: '#EDEDED'
    property color panelColor: '#FFFFFF'
    property color panelOverlay: '#EDEDED'

    // Base Text
    property color baseFontColor: '#5d5d5d'
    property color baseLinkColor: 'blue'

    // Posts
    property color postItemBackgroundColor: Qt.lighter(backgroundColor, 1.5)
    property color postItemBorderColor:  Qt.darker(backgroundColor, 1.5)
    property color postItemHeaderColor: baseLinkColor
    property color postItemFontColor: baseFontColor

    // Comments
    property color commentBackgroundColorEven: Qt.lighter('#EDEDED', 1.05)
    property color commentBackgroundColorOdd: Qt.darker(commentBackgroundColorEven, 1.05)
    property color commentFontColor: baseFontColor
    property color commentLinkColor: baseLinkColor

    // Messages
    property color messageBackgroundColor: commentBackgroundColorOdd
    property color messageFontColor: baseFontColor
    property color messageLinkColor: baseLinkColor

    // Sharing
    property color shareBackgroundColor: commentBackgroundColorEven
}
