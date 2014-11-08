import QtQuick 2.0

Flickable {
    id: display
    contentWidth: parent.width
    contentHeight: contentItem.childrenRect.height

    // List model that feeds the view
    property var model

    // Component to be used to display each item
    property Component delegate

    // Number of columns to use
    property int columns: 1
    property var columnItems: Array()

    property int rowSpacing: 0
    property int colSpacing: 0

    Row {
        width: parent.width
        spacing: rowSpacing

        Repeater {
            model: columns
            onModelChanged: {
                console.log('Number of columns changed to: '+columns);
                update();
                loadItems();
            }
            Column {
                spacing: colSpacing
                width: parent.width / columns
                Component.onCompleted: {
                    console.log("Created Column: "+index)
                    columnItems[index] = this
                }
            }
        }
    }

    Component {
        id: delegateItemLoader

        Loader {
            property variant model
            width: display.contentItem.width / columns
        }
    }

    Component.onCompleted: {
        console.log('Creating list view with '+columns+' columns')
        loadItems();
    }

    function loadItems() {
        console.log('Loading items from model')
        if (model === null) {
            console.log("No model defined, nothing to load")
            return;
        }

        var lastColumn = -1;
        for (var i = 0; i < model.count; i++) {
            var modelObject = model.get(i);

            var properties = {
                'sourceComponent': delegate,
                'model': modelObject,
                'index': i,

            }

            if (lastColumn >= columns-1) {
                lastColumn = 0;
            } else {
                lastColumn++;
            }

            var delegateItem = delegateItemLoader.createObject(columnItems[lastColumn], properties)
        }
    }
}
