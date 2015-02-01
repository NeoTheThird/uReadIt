import QtQuick 2.0

Flickable {
    id: display
    contentWidth: parent.width - (anchors.margins*2)
    contentHeight: contentItem.childrenRect.height

    // List model that feeds the view
    property var model
    property int lastModelItemIndex: 0
    property int lastColumnUsed: -1
    property bool isLoading: false
    property bool isLoaded: true

    // Component to be used to display each item
    property Component delegate

    // Number of columns to use
    property int columns: 1
    property var columnItems: Array()

    // Vertical and horizontal spacing between delegate components
    property int rowSpacing: 0
    property int colSpacing: 0

    // Attempt to balance column sizes by adding items to the shortest
    // column, rather than the next one in order
    property bool balanced: false
    property var columnHeights: Array()

    function clear() {
        isLoaded = false
        isLoading = true
        var existingColumns = columnItems.length
        for (var i = 0; i < existingColumns; i++) {
            if (columnItems[i].children == null)
                continue;
            var childCount = columnItems[i].children.length
            for (var j = columnItems[i].children.length-1; j >= 0; j--) {
                //console.log('i='+i+', j='+j)
                columnItems[i].children[j].destroy()
                delete columnItems[i].children[j];
            }
            columnHeights[i] = 0;
        }
        isLoading = false
        isLoaded = true
    }

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
            width: parent.width / columns
            Column {
                spacing: colSpacing
                Component.onCompleted: {
                    //console.log("Created Column: "+index)
                    columnItems[index] = this;
                    columnHeights[index] = 0;
                }
            }
        }
    }

    Component {
        id: hiddenDelegate

        Rectangle {
            id: hiddenDelegatePlaceholder
        }
    }

    Component {
        id: delegateItemLoader

        Loader {
            property variant model
            property int index
            property int fixedHeight
            width: (display.contentItem.width - (rowSpacing * (columns-1))) / columns

            opacity: ((y+height) >= display.contentY) && (y <= (display.contentY + display.height)) ? 1 : 0
            onOpacityChanged: {

                if (this.hasOwnProperty('item') && this.item != null) {
                    //console.log('Loader item opacity changed to: '+opacity)
                    if (opacity > 0.0) {
                        this.item.visible = true;
                        this.sourceComponent = delegate;
                    } else {
                        this.height = this.item.height
                        this.item.visible = false;
                        this.sourceComponent = hiddenDelegate;
                    }
                }
            }
        }
    }

    Connections {
        target: model

        onCountChanged: {
            // TODO: Be smarter about items being removed
            if (model.count < lastModelItemIndex) {
                lastModelItemIndex = 0;
                clear();
            } else {
                loadFrom(lastModelItemIndex);
            }
        }
    }

    function getNextColumn() {
        if (balanced) {
            var shortestColumn = -1
            var shortestColumnHeight = -1
            for (var colId = columns-1; colId >= 0; colId--) {
                if (shortestColumnHeight == -1 || columnHeights[colId] < shortestColumnHeight) {
                    shortestColumn = colId;
                    shortestColumnHeight = columnHeights[colId];
                }
            }
            return shortestColumn;
        } else {
            if (lastColumnUsed >= columns-1) {
                lastColumnUsed = 0;
            } else {
                lastColumnUsed++;
            }
        }
        return lastColumnUsed;
    }


    function loadFrom(start) {
        if (isLoaded == false) {
            //console.log('Initial load hasn\'t finished, aborting')
            return
        }
        if (isLoading == true) {
            //console.log('Another load is in progress, aborting')
            return
        }
        isLoading = true

        //console.log('Loading more items')
        lastModelItemIndex = model.count
        for (var i = start; i < model.count; i++) {
            //console.log("Post: "+i);
            var modelObject = model.get(i);

            var properties = {
                'sourceComponent': delegate,
                'model': modelObject,
                'index': i,

            }

            var colIndex = getNextColumn();

            var delegateItem = delegateItemLoader.createObject(columnItems[colIndex], properties)
            //console.log('New item height: '+delegateItem.height)
            columnHeights[colIndex] += delegateItem.height + rowSpacing
        }
        isLoading = false

    }

    function loadItems() {
        if (isLoading) {
            //console.log('Another load is in progress, aborting')
            return;
        }
        isLoading = true

        //console.log('Loading items from model')
        if (model === null) {
            //console.log("No model defined, nothing to load")
            return;
        }

        for (var i = 0; i < model.count; i++) {
            lastModelItemIndex = i
            var modelObject = model.get(i);

            var properties = {
                'sourceComponent': delegate,
                'model': modelObject,
                'index': i,

            }

            var colIndex = getNextColumn();

            var delegateItem = delegateItemLoader.createObject(columnItems[colIndex], properties)
            //console.log('New item height: '+(delegateItem.height + rowSpacing))
            columnHeights[colIndex] += 0 + delegateItem.height + rowSpacing
        }
        isLoading = false;
    }

}
