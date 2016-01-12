import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.0 as ListItems
import Ubuntu.Components.Popups 1.0

Page {
    id: accountsPage
    title: "User Accounts"

    head.actions: [
        Action {
            id: addAccountAction
            text: "Add Account"
            iconName: 'new-contact'
            onTriggered: {
                PopupUtils.open(addAccountComponent)
            }
        }

    ]
    ListView {
        id: accountsList
        anchors.fill: parent

        model: uReadIt.qreddit.getUsers()

        delegate: ListItems.Standard {
            text: modelData || "Anonymous"
            progression: true
            removable: (modelData) ? true : false
            confirmRemoval: true
            iconName: 'contact'
            iconSource: {
                if (!modelData) {
                    return ""
                } else if (uReadIt.qreddit.notifier.isLoggedIn && modelData == uReadIt.qreddit.notifier.activeUser) {
                    return Qt.resolvedUrl('../images/contact-active.svg')
                } else {
                    return Qt.resolvedUrl('../images/contact.svg')
                }
            }

            onClicked: {
                if (modelData == null) {
                    // Anonymous user
                    uReadIt.qreddit.logout()
                    mainStack.pop()
                    return
                }

                var loginConnObj = null;
                if (modelData == uReadIt.qreddit.notifier.activeUser) {
                    loginConnObj = uReadIt.qreddit.loginActiveUser()
                } else {
                    loginConnObj = uReadIt.qreddit.switchActiveUser(modelData);
                }

                loginConnObj.onSuccess.connect(function(response) {
                    mainStack.pop()
                })
                loginConnObj.onError.connect(function(response) {
                    console.log('Error reponse: '+response)
                    //editAccountDialog.text = "Error: "+response
                    //editAccountDialog.username = modelData
                    PopupUtils.open(editAccountComponent, null, {'username':modelData, 'text':response})
                })
            }

            onItemRemoved: {
                uReadIt.qreddit.deleteUser(modelData)
            }
        }
    }

    Component {
        id: editAccountComponent

        Dialog {
            id: editAccountDialog
            property string username: ""
            title: "Change Password for: "+username

            TextField {
                id: editPasswordField
                placeholderText: "Password"
                width: parent.width
                text: ""
                echoMode: TextInput.PasswordEchoOnEdit
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
            }
            Button {
                id: editConfirmButton
                text: "Save"
                gradient: UbuntuColors.orangeGradient
                onClicked: {
                    uReadIt.qreddit._addUser(username, editPasswordField.text)
                    PopupUtils.close(editAccountDialog)
                }
            }
            Button {
                id: addCancelButton
                text: "Cancel"
                onClicked: {
                    PopupUtils.close(editAccountDialog)
                }
            }
        }
    }
    Component {
        id: addAccountComponent

        Dialog {
            id: addAccountDialog
            title: "Add User Account"

            TextField {
                id: addUsernameField
                placeholderText: "Username"
                width: parent.width
                //text: ""
                //inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
            }
            TextField {
                id: addPasswordField
                placeholderText: "Password"
                width: parent.width
                text: ""
                echoMode: TextInput.PasswordEchoOnEdit
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
            }
            Button {
                id: addConfirmButton
                text: "Save"
                gradient: UbuntuColors.orangeGradient
                onClicked: {
                    uReadIt.qreddit._addUser(addUsernameField.text, addPasswordField.text)
                    PopupUtils.close(addAccountDialog)
                }
            }
            Button {
                id: addCancelButton
                text: "Cancel"
                onClicked: {
                    PopupUtils.close(addAccountDialog)
                }
            }
        }
    }
}
