import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4

ApplicationWindow {
    id: window
    visible: true
    title: "Hello World"

    TreeWidget{
        id: tree
        anchors.fill: parent

        Component.onCompleted: {
            iconSize = (Qt.size(20, 20));
            font.pointSize = 30

            var topItem1 = createItem("Item 1", "ico_item.png");
            topItem1.setSelectionFlag(selectionCurrent);
            addTopLevelItem(topItem1);

            topItem1.appendChild(createItem("Child 1", "ico_item.png"));
            topItem1.appendChild(createItem("Child 2", "ico_item.png"));
            topItem1.appendChild(createItem("Child 3", "ico_item.png"));

            addTopLevelItem(createItem("Item 2", "ico_item.png"));
            addTopLevelItem(createItem("Item 3", "ico_item.png"));
        }

        onCurrentItemChanged: {
            var item = getCurrentItem();
            if(item) inputName.text = item.text();
        }

    }

    Dialog{
        id: dlgRename
        modal: true
        width: window.width - 20
        x: window.width / 2 - width / 2
        y: window.height / 2 - height / 2
        title: "Rename item ..."
        visible: false
        standardButtons: Dialog.Ok | Dialog.Cancel

        property alias initName: inputName.text

        contentItem: Rectangle{
            width: dlgRename.width
            height: inputName.implicitHeight + 6
            color: "lightGray"
            TextInput{
                id: inputName
                clip: true
                text: "input here"
                x: 10
                width: parent.width
                font.pointSize: 20
                color: "black"

                anchors.verticalCenter: parent.verticalCenter

                onAccepted: {
                    dlgRename.accept();
                    dlgRename.close();
                }
            }
        }

        onAccepted: {
            var curItem = tree.getCurrentItem();
            if(curItem){
                curItem.setText(inputName.text);
            }
        }
    }

    ToolBar{
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        RowLayout{
            spacing: 0
            ToolButton{
                id: buttonAdd
                text: "Add Node ..."

                onClicked: {
                    menuAdd.popup();
                }

                menu: Menu{
                    id: menuAdd
                    title: "Add Node"

                    MenuItem{
                        text: "Child"
                        onTriggered: {
                            var curItem = tree.getCurrentItem();
                            if(curItem){
                                curItem.appendChild(tree.createItem("Child", "ico_item.png"));
                                curItem.setExpanded(true);
                            }
                        }
                    }

                    MenuItem {
                        text: "Sibling Before"
                        onTriggered: {
                            var curItem = tree.getCurrentItem();
                            if(curItem){
                                var parentItem = curItem.parent();
                                if(parentItem){
                                    var pos = parentItem.indexOfChildItem(curItem);
                                    parentItem.insertChild(pos, tree.createItem("Item Before", "ico_item.png"));
                                }
                            }
                        }
                    }

                    MenuItem {
                        text: "Sibling After"
                        onTriggered: {
                            var curItem = tree.getCurrentItem();
                            if(curItem){
                                var parentItem = curItem.parent();
                                if(parentItem){
                                    var pos = parentItem.indexOfChildItem(curItem);
                                    if(pos < parentItem.childernCount() - 1){
                                        parentItem.insertChild(pos + 1, tree.createItem("Item After", "ico_item.png"));
                                    }else{
                                        parentItem.appendChild(tree.createItem("Item After", "ico_item.png"));
                                    }
                                }
                            }
                        }
                    }
                }
            }

            ToolSeparator{}

            ToolButton{
                id: buttonRename
                text: "Rename ..."

                onClicked: {
                    var curItem = tree.getCurrentItem();
                    if(curItem){
                        dlgRename.initName = curItem.text();
                        dlgRename.open();
                    }
                }
            }

            ToolSeparator{}

            ToolButton{
                id: buttonDelete
                text: "Delete"

                onClicked: {
                    var curItem = tree.getCurrentItem();
                    if(curItem){
                        var parentItem = curItem.parent();
                        if(parentItem){
                            parentItem.removeChild(curItem);
                        }
                    }
                }
            }
        }
    }
}
