import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.Themes.Ambiance 0.1

QtObject {
    // MainView
    property color backgroundColor: '#EDEDED'
    property color panelColor: Qt.darker(Theme.palette.normal.background, 1.2)
    property color panelOverlay: '#EDEDED'

    // Base Text
    property color baseFontColor: UbuntuColors.darkGrey
    property color baseLinkColor: UbuntuColors.blue

    // Posts
    property color postItemBackgroundColor: Qt.lighter(backgroundColor, 1.5)
    property color postItemBorderColor:  Qt.darker(backgroundColor, 1.2)
    property color postItemHeaderColor: baseFontColor
    property color postItemFontColor: baseFontColor

    // Comments
    property color commentBackgroundColorEven: Qt.lighter(backgroundColor, 1.05)
    property color commentBackgroundColorOdd: Qt.darker(commentBackgroundColorEven, 1.05)
    property color commentFontColor: baseFontColor
    property color commentLinkColor: baseLinkColor

    // Messages
    property color messageBackgroundColor: commentBackgroundColorOdd
    property color messageFontColor: baseFontColor
    property color messageLinkColor: baseLinkColor

    // Sharing
    property color shareBackgroundColor: Qt.lighter(backgroundColor)
}
