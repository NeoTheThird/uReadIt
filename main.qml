import QtQuick 2.0
import Ubuntu.Components 1.1
import "ui" as UI

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "com.ubuntu.developer.mhall119.ureadit"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true

    // Removes the old toolbar and enables new features of the new header.
    useDeprecatedToolbar: false

    width: units.gu(60)
    height: units.gu(75)

    headerColor: "#333333"
    backgroundColor: "#444444"
    footerColor: "#555555"
    UI.Frontpage {
        id: frontpage
    }
}

