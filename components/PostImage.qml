import QtQuick 2.0

Image {
    id: postThumbnail
    fillMode: Image.PreserveAspectFit
    property string url
    property string thumbnail
    property bool hires: false
    source: ""

    onUrlChanged: update_source()
    onOpacityChanged: update_source()
    function update_source() {
        //console.log('Link: '+url)

        if (opacity == 0) {
            console.log('Unloading image: '+source)
            source = ""
        }

        if (thumbnail == 'nsfw') {
            source = Qt.resolvedUrl('../images/nsfw2.png')
        }

        if (thumbnail == 'default') {
            source = ""
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
