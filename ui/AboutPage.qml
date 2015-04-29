import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItems

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
            value: "ureadit-dev"
        }
        ListItems.SingleValue {
            text: i18n.tr("Author")
            value: "Michael Hall (mhall119)"
        }
        ListItems.SingleValue {
            text: i18n.tr("Version")
            value: "3.9"
        }
        ListItems.SingleValue {
            text: i18n.tr("Released")
            value: "2015-04-28"
        }
    }
}
