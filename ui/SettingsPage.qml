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

        ListItems.Header {
            text: "Startup"
        }
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

        ListItems.Header {
            text: "Internal Browser"
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

        ListItems.Header {
            text: "Image Previews"
        }

        OptionSelector {
            id: previewOptions
            width: parent.width - units.gu(4)
            anchors.horizontalCenter: parent.horizontalCenter
            selectedIndex: uReadIt.settings.showPreviews
            model: ListModel {
                ListElement { value: 0; name: "Don't show images" }
                ListElement { value: 1; name: "Show large previews" }
                ListElement { value: 2; name: "Show thumbnail previews" }
            }
            delegate: OptionSelectorDelegate { text: name }
            onDelegateClicked: {
                uReadIt.settings.showPreviews = index;
            }
        }
        ListItems.Header {
            text: "Theme"
        }

        OptionSelector {
            id: themeOptions
            width: parent.width - units.gu(4)
            anchors.horizontalCenter: parent.horizontalCenter

            selectedIndex: uReadIt.themeManager.currentThemeIndex
            model: uReadIt.themeManager.themes

            delegate: OptionSelectorDelegate { text: modelData.name }
            onDelegateClicked: {
                var themeElement = uReadIt.themeManager.themes[index]
                console.log("Changing theme to "+themeElement.name)
                uReadIt.settings.themeName = themeElement.source
                uReadIt.themeManager.currentThemeIndex = index
            }
        }
    }
}
