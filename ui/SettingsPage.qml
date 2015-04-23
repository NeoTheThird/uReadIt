import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItems
import Ubuntu.Components.Popups 1.0

Page {
    id: settingsPage
    title: i18n.tr("Settings")

    Column {
        id: accountsList
        anchors.fill: parent

        ListItems.Header {
            text: i18n.tr("Startup")
        }
        ListItems.Standard {
            text: i18n.tr("Login automatically at startup")
            control: Switch {
                id: autoLoginCheckbox
                checked: uReadIt.settings.autoLogin
                onCheckedChanged: {
                    uReadIt.settings.autoLogin = autoLoginCheckbox.checked
                }
            }
        }

        ListItems.Header {
            text: i18n.tr("Internal Browser")
        }

        ListItems.Standard {
            text: i18n.tr("Open links internally")
            control: Switch {
                id: useInternalBrowserCheckbox
                checked: uReadIt.settings.useInternalBrowser
                onCheckedChanged: {
                    uReadIt.settings.useInternalBrowser = useInternalBrowserCheckbox.checked
                }
            }
        }

        ListItems.Header {
            text: i18n.tr("Image Previews")
        }

        OptionSelector {
            id: previewOptions
            width: parent.width - units.gu(4)
            anchors.horizontalCenter: parent.horizontalCenter
            selectedIndex: uReadIt.settings.showPreviews
            model: ListModel {
                ListElement { value: 0; name: i18n.tr("Don't show images") }
                ListElement { value: 1; name: i18n.tr("Show large previews") }
                ListElement { value: 2; name: i18n.tr("Show thumbnail previews") }
            }
            delegate: OptionSelectorDelegate { text: name }
            onDelegateClicked: {
                uReadIt.settings.showPreviews = index;
            }
        }
        ListItems.Header {
            text: i18n.tr("Theme")
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
                uReadIt.settings.themeName = themeElement.source
                uReadIt.themeManager.currentThemeIndex = index
            }
        }
    }
}
