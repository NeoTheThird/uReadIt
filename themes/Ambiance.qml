import QtQuick 2.0
import Ubuntu.Components 1.1

QtObject {
    // MainView
    property color backgroundColor: Theme.palette.normal.background
    property color panelColor: Qt.darker(Theme.palette.normal.background, 1.2)

    // Base Text
    property color baseFontColor: UbuntuColors.warmGrey
    property color baseLinkColor: Theme.palette.selected.foreground

    // Posts
    property color postItemBackgroundColor: Qt.lighter(backgroundColor, 1.5)
    property color postItemBorderColor:  Qt.darker(backgroundColor, 1.2)
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
}
