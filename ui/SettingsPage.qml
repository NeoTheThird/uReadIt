import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItems
import Ubuntu.Components.Popups 1.0

Page {
    id: settingsPage
    title: "Settings"

    Column {
        id: accountsList
        anchors.fill: parent

        ListItems.Standard {
            text: "Login automatically at startup"
            control: Switch {
                id: autoLoginCheckbox
                checked: uReadIt.settings.autoLogin
                onCheckedChanged: {
                    uReadIt.settings.autoLogin = autoLoginCheckbox.checked
                }
            }
        }
        ListItems.Standard {
            text: "Open links internally"
            control: Switch {
                id: useInternalBrowserCheckbox
                checked: uReadIt.settings.useInternalBrowser
                onCheckedChanged: {
                    uReadIt.settings.useInternalBrowser = useInternalBrowserCheckbox.checked
                }
            }
        }

    }
}
