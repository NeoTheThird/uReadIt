import QtQuick 2.4

Image {
    id: postThumbnail
    fillMode: Image.PreserveAspectFit
    property string url
    property string thumbnail
    property bool hires: false
    source: ""
    asynchronous: true

    onUrlChanged: update_source()

    function update_source() {
        if (!visible) {
            //console.log('Unloading image: '+source)
            //source = ""
            return
        }

        if (thumbnail == 'nsfw') {
            source = Qt.resolvedUrl('../images/nsfw2.png')
            return
        }

        if (thumbnail == 'default') {
            source = ""
            return
        }

        var ext = url.substring(url.length - 4)
        if (ext == '.gif' || ext == '.jpg') {
            hires = true;
            source = url;
        } else {
            hires = false;
            source = thumbnail;
        }

    }

}
