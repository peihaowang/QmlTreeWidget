import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2

ApplicationWindow {
    id: window
    visible: true
    width: 640
    height: 480
    title: "QmlTreeWidget Example"

    readonly property string iconName: "ico_item.png"

    TreeWidget{
        id: tree
        anchors.fill: parent

        Component.onCompleted: {
            iconSize = (Qt.size(12, 12));
            font.family = "Monaco";
            font.pointSize = 16;

            var topItem1 = createItem("Item 1", iconName);
            topItem1.setSelectionFlag(selectionCurrent);
            addTopLevelItem(topItem1);

            topItem1.appendChild(createItem("Child 1", iconName));
            topItem1.appendChild(createItem("Child 2", iconName));
            topItem1.appendChild(createItem("Child 3", iconName));

            addTopLevelItem(createItem("Item 2", iconName));
            addTopLevelItem(createItem("Item 3", iconName));
        }

        onCurrentItemChanged: {
            var item = getCurrentItem();
            if(item) inputName.text = item.text();
        }

    }

    Dialog{
        id: dlgRename
        title: "Rename item ..."
        width: window.width / 2
        visible: false
        standardButtons: Dialog.Ok | Dialog.Cancel

        property alias initName: inputName.text

        ColumnLayout{
            anchors.fill: parent

            Text{
                text: "Enter the new name of the current selected item"
            }

            Rectangle{

                height: inputName.height

                color: "lightGray"

                TextInput{
                    id: inputName
                    clip: true
                    x: 10
                    width: parent.width
                    font.pointSize: 20
                    color: "black"

                    anchors.verticalCenter: parent.verticalCenter

                    onAccepted: {
                        dlgRename.close();
                    }
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
            Button{
                id: buttonAddChild
                text: "Add Child"

                onClicked: {
                    var curItem = tree.getCurrentItem();
                    if(curItem){
                        curItem.appendChild(tree.createItem("Child", iconName));
                        curItem.setExpanded(true);
                    }
                }
            }

            ToolSeparator{}

            Button{
                id: buttonAddBefore
                text: "Add Before"

                onClicked: {
                    var curItem = tree.getCurrentItem();
                    if(curItem){
                        var parentItem = curItem.parent();
                        if(parentItem){
                            var pos = parentItem.indexOfChildItem(curItem);
                            parentItem.insertChild(pos, tree.createItem("Item Before", iconName));
                        }
                    }
                }
            }

            ToolSeparator{}

            Button{
                id: buttonAddAfter
                text: "Add After"
                onClicked: {
                    var curItem = tree.getCurrentItem();
                    if(curItem){
                        var parentItem = curItem.parent();
                        if(parentItem){
                            var pos = parentItem.indexOfChildItem(curItem);
                            if(pos < parentItem.childernCount() - 1){
                                parentItem.insertChild(pos + 1, tree.createItem("Item After", iconName));
                            }else{
                                parentItem.appendChild(tree.createItem("Item After", iconName));
                            }
                        }
                    }
                }
            }

            ToolSeparator{}

            Button{
                id: buttonRename
                text: "Rename"

                onClicked: {
                    var curItem = tree.getCurrentItem();
                    if(curItem){
                        dlgRename.initName = curItem.text();
                        dlgRename.open();
                    }
                }
            }

            ToolSeparator{}

            Button{
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
