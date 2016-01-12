import QtQuick 2.4
import Ubuntu.Components 1.3

QtObject {
    property string baseThemeName: "Ubuntu.Components.Themes.SuruDark"

    // MainView
    property color backgroundColor: UbuntuColors.coolGrey
    property color backgroundHeaderColor: UbuntuColors.coolGrey
    property color backgroundFooterColor: UbuntuColors.coolGrey
    property color panelColor: Qt.darker('#333333')
    property color panelOverlay: '#000000'

    // Base Text
    property color baseFontColor: UbuntuColors.warmGrey
    property color baseLinkColor: 'lightblue'

    // Posts
    property color postItemBackgroundColor: "#222222"
    property color postItemBorderColor: "#111111"
    property color postItemHeaderColor: baseFontColor
    property color postItemFontColor: baseFontColor

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
    property color shareBackgroundColor: Qt.darker(backgroundColor)

}

