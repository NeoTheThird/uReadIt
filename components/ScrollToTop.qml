import QtQuick 2.4

MouseArea {
    anchors.fill: parent

    property Flickable target

    Component.onCompleted: console.log("ScrollToTop created")
    onClicked: {
        console.log("ScrollToTop clicked")
        target.contentY = this.height * -1
    }
}
