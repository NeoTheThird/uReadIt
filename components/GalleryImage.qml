import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    id: delegate
    property string title
    property string sourceUrl
    property string thumbnailUrl
    property alias progress: image.progress
    property alias imageStatus: image.status
    property bool isZoomed: flickable.sizeScale != 1.0
    property bool pinchInProgress: zoomPinchArea.active
    property bool isInteractive: pinchInProgress || isZoomed

    function zoomIn(centerX, centerY, factor) {
        flickable.scaleCenterX = centerX / (flickable.sizeScale * flickable.width);
        flickable.scaleCenterY = centerY / (flickable.sizeScale * flickable.height);
        flickable.sizeScale = factor;
    }

    function zoomOut() {
        if (flickable.sizeScale != 1.0) {
            flickable.scaleCenterX = flickable.contentX / flickable.width / (flickable.sizeScale - 1);
            flickable.scaleCenterY = flickable.contentY / flickable.height / (flickable.sizeScale - 1);
            flickable.sizeScale = 1.0;
        }
    }

    Component.onCompleted: console.log('Created GalleryImage: '+sourceUrl )
    Component.onDestruction: console.log('Destroying GalleryImage')
    PinchArea {
        id: zoomPinchArea
        anchors.fill: parent

        property real initialZoom
        property real maximumScale: 3.0
        property real minimumZoom: 1.0
        property real maximumZoom: 3.0
        property bool active: false
        property var center

        onPinchStarted: {
            active = true;
            initialZoom = flickable.sizeScale;
            center = zoomPinchArea.mapToItem(image, pinch.startCenter.x, pinch.startCenter.y);
            zoomIn(center.x, center.y, initialZoom);
        }
        onPinchUpdated: {
            var zoomFactor = MathUtils.clamp(initialZoom * pinch.scale, minimumZoom, maximumZoom);
            flickable.sizeScale = zoomFactor;
        }
        onPinchFinished: {
            active = false;
        }

        Flickable {
            id: flickable
            anchors.fill: parent
            contentWidth: image.height
            contentHeight: image.height
            contentX: (sizeScale - 1) * scaleCenterX * width
            contentY: (sizeScale - 1) * scaleCenterY * height
            interactive: !delegate.pinchInProgress && delegate.isZoomed

            boundsBehavior: Flickable.StopAtBounds

            property real sizeScale: 1.0
            property real scaleCenterX: 0.0
            property real scaleCenterY: 0.0
            Behavior on sizeScale {
                enabled: !delegate.pinchInProgress
                UbuntuNumberAnimation {duration: UbuntuAnimation.FastDuration}
            }
            Behavior on scaleCenterX {
                UbuntuNumberAnimation {duration: UbuntuAnimation.FastDuration}
            }
            Behavior on scaleCenterY {
                UbuntuNumberAnimation {duration: UbuntuAnimation.FastDuration}
            }


            MouseArea {
                width: flickable.width * flickable.sizeScale
                height: flickable.height * flickable.sizeScale

                AnimatedImage {
                    id: image
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit;
                    source: delegate.sourceUrl
                    asynchronous: true
                    cache: false
                    opacity: (status == Image.Ready && delegate.ListView.isCurrentItem) ? 1.0 : 0.0
                    playing: delegate.ListView.isCurrentItem
                }
                Image {
                    id: thumbnail
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit;
                    source: delegate.thumbnailUrl
                    asynchronous: true
                    cache: false
                    opacity: image.status == Image.Ready ?0.0 : 1.0
                }
                ActivityIndicator {
                    id: loadingIndicator
                    anchors.centerIn: parent
                    running: image.status == Image.Loading
                }

                onClicked: {
                    if (image.playing) {
                        image.paused = !image.paused
                    }
                }

                onDoubleClicked: {
                    if (delegate.parent.moving) {
                        // FIXME: workaround for Qt bug specific to touch:
                        // doubleClicked is received even though the MouseArea
                        // was tapped only once but another MouseArea was also
                        // tapped shortly before.
                        // Ref.: https://bugreports.qt.io/browse/QTBUG-39332
                        return;
                    }
                    if (flickable.sizeScale < zoomPinchArea.maximumZoom) {
                        zoomIn(mouse.x, mouse.y, zoomPinchArea.maximumZoom);
                    } else {
                        zoomOut();
                    }
                }
            }
        }
    }
}
