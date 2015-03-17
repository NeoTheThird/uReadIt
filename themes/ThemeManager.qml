import QtQuick 2.0
import Ubuntu.Components 1.1

QtObject {
    id: themeManager

    property QtObject theme
    property var themes
    property string source
    property int currentThemeIndex: -1

    onSourceChanged: {
        var themeComponent = Qt.createComponent(source)
        if (themeComponent.status == Component.Ready) {
            themeManager.theme = themeComponent.createObject(themeManager)
        }
        for (var i in themes) {
            if (themes[i].source === themeManager.source) {
                themeManager.currentThemeIndex = i;
                break;
            }
        }
    }

    onCurrentThemeIndexChanged: {
        themeManager.source = themes[currentThemeIndex].source
    }

}

