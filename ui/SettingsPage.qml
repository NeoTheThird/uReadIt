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
            selectedIndex: {
                if (uReadIt.theme.name == "RedditDark.qml") {
                    return 0;
                } else if (uReadIt.theme.name == "Ambiance.qml") {
                    return 1;
                } else if (uReadIt.theme.name == "RedditLight.qml") {
                    return 2;
                }
            }

            model: ListModel {
                ListElement { theme: "RedditDark.qml"; name: "uReadIt (Dark)" }
                ListElement { theme: "Ambiance.qml"; name: "Ambiance (Light)" }
                ListElement { theme: "RedditLight.qml"; name: "Reddit (Blue)" }
            }
            delegate: OptionSelectorDelegate { text: name }
            onDelegateClicked: {
                var themeElement = themeOptions.model.get(index)
                uReadIt.settings.themeName = themeElement.theme
                uReadIt.theme.name = themeElement.theme
            }
        }
    }
}
