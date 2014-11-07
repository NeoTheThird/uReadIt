import QtQuick 2.0
import Ubuntu.Components 1.1

Item {

    // List model that feeds the view
    property var model

    // Component to be used to display each item
    property Component delegate

    // How wide to make a column before creating another
    property int maxColumnWidth

    Component.onCompleted: {
        loadItems();
    }

    function loadItems() {
        if (model == null) {
            console.log("No model defined, nothing to load")
            return;
        }

        for (var i = 0; i < model.count; i++) {
            console.log("Loading index: "+i)
            var modelObject = model.get(i);
            console.log('Model: '+modelObject);
            console.log('Delegate: '+delegate);
            for(var k in delegate) {
                console.log('  '+k+': '+delegate[k])
            }

            var properties = {
                'model': modelObject,
                'index': i,
            }

            var delegateItem = delegate.createObject(display.contentItem, properties)
            itemManager.placeObject(delegateItem)
        }
    }

    Flickable {
        id: display

        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: contentItem.childrenRect.height

    }
    property alias flickable: display

    // Component responsible for placing child items
    QtObject {
        id: itemManager

        property int lastItemRight: 0
        property int lastItemBottom: 0

        function placeObject(obj) {
            obj.y = lastItemBottom
            lastItemBottom += obj.height
            obj.x = 0
        }
    }

}
