import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItems
import "../manifest.js" as Manifest

Page {
    id: aboutPage
    title: i18n.tr("About")

    Column {
        id: detailsList
        anchors.fill: parent

        UbuntuShape {
            anchors.horizontalCenter: parent.horizontalCenter
            height: units.gu(25)
            width: units.gu(25)
            radius: "medium"

            image: Image {
                source: Qt.resolvedUrl("../images/Reddit.png")
            }
        }

        ListItems.SingleValue {
            text: i18n.tr("Name")
            value: Manifest.appData.title
        }
        ListItems.SingleValue {
            text: i18n.tr("Author")
            value: Manifest.appData.maintainer
        }
        ListItems.SingleValue {
            text: i18n.tr("Version")
            value: Manifest.appData.version
        }
        ListItems.SingleValue {
            text: i18n.tr("Released")
            value: Manifest.releaseDate
        }
    }
}

