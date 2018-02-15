import QtQuick 2.0
import QtQuick.Controls 2.3
import "TreeItem.js" as TreeItem

Rectangle{

    id: panel

    property var rootItem: new TreeItem.TreeItem("", "", null)
    property var currentItem: null

    // ENUM: Selection Flag
    readonly property int selectionNone: TreeItem.SF_None
    readonly property int selectionCurrent: TreeItem.SF_Current
    readonly property int selectionSelected: TreeItem.SF_Selected

    // The size of tree node icon. By default, this property has a value of Qt.size(14, 14).
    property size iconSize: Qt.size(14, 14)
    // The font of tree node text. By default, this property has a value of Qt.font({family:"Monaco", pointSize:16}).
    property font font: Qt.font({family:"Monaco", pointSize:16})

    // Stylesheet
    // The backgroud color of the whole tree view panel. By default, this color is set to black
    readonly property color backgroundFill: Qt.rgba(33/255, 37/255, 43/255)
    // The background color of tree nodes. By default, this color is set to transparent(which means showing the background of the tree view).
    readonly property color backgroundNormal: Qt.rgba(0.0, 0.0, 0.0, 0.0)
    // The foreground color of tree node text. By default, this color is set to pale.
    readonly property color foregroundNormal: Qt.rgba(151/255, 165/255, 180/255)
    // The background color of hovered tree nodes. By default, this color is set to dark black.
    readonly property color backgroundHovered: Qt.rgba(44/255, 49/255, 58/255)
    // The foreground color of hovered tree node text. By default, this color is set to white.
    readonly property color foregroundHovered: Qt.rgba(1.0, 1.0, 1.0)   // white
    // The background color of the current tree node. By default, this color is set to dark black.
    readonly property color backgroundCurrent: Qt.rgba(24/255, 26/255, 31/255)
    // The foreground color of the current tree node text. By default, this color is set to white.
    readonly property color foregroundCurrent: Qt.rgba(1.0, 1.0, 1.0)   // white
    // The color of the flag which indicates the selected nodes. By default, this color is set to steel blue.
    readonly property color selectionFlagColor: Qt.rgba(86/255, 138/255, 242/255)

    // The uri of expand icon resource. Or put the default icon resource into the directory same with TreeWidget.qml and use the default icon "btn_expand.png".
    readonly property string uriExpandIcon: "btn_expand.png"
    // The uri of collapse icon resource. Or put the default icon resource into the directory same with TreeWidget.qml and use the default icon "btn_collapse.png".
    readonly property string uriCollapseIcon: "btn_collapse.png"

    implicitWidth: 200
    implicitHeight: parent.height
    color: backgroundFill

    //Model
    ListModel{
        id: listModel
    }

    //Delegate
    Component{
        id: delegateRoot
        Column{
            Repeater{
                model: subNodes
                delegate: delegateItems
            }
        }
    }

    Component{
        id: delegateItems
        Column{
            Rectangle{
                id: itemRect
                width: listView.width
                height: itemRow.implicitHeight + 6

                color: (selectionFlag == TreeItem.SF_Current) ? backgroundCurrent : backgroundNormal

                function getItemByID(id){
                    var item = parentNode, vPath = [itemID];
                    while(item){
                        vPath.splice(0, 0, item.itemID);
                        item = item.parentNode;
                    }

                    var children = [rootItem];
                    for(var i = 0; i < vPath.length; i++){
                        var bFound = false;
                        for(var j = 0; j < children.length; j++){
                            var child = children[j];
                            if(vPath[i] === child.itemID){
                                if(i == vPath.length - 1){
                                    return child;
                                }else{
                                    children = child.subNodes;
                                    bFound = true;
                                    break;
                                }
                            }
                        }
                        if(!bFound){
                            return null;
                        }
                    }
                }

                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        itemRect.color = backgroundHovered;
                        textTitle.color = foregroundHovered;
                    }
                    onExited: {
                        itemRect.color = Qt.binding(function(){return ((selectionFlag == TreeItem.SF_Current) ? backgroundCurrent : backgroundNormal);});
                        textTitle.color = Qt.binding(function(){return ((selectionFlag == TreeItem.SF_Current) ? foregroundCurrent : foregroundNormal);});
                    }
                    onClicked: {
                        var item = itemRect.getItemByID();
                        if(currentItem) currentItem.setSelectionFlag(TreeItem.SF_None);
                        if(item){
                            item.setSelectionFlag(TreeItem.SF_Current);
                        }
                    }
                }

                Row{
                    id: itemRow
                    anchors.verticalCenter: itemRect.verticalCenter

                    // Selection Flag
                    Rectangle{
                        width: 3
                        height: parent.height
                        color: selectionFlag != TreeItem.SF_None ? selectionFlagColor : "transparent"
                    }

                    // Indent
                    Item{
                        width: getIndent();
                        height: parent.height

                        // 2018.2.10 Delegate somehow cannot call the attached functions, so reimplement getLevel() here
                        function getIndent(){
                            var item = itemRect.getItemByID();
                            return (item ? item.level() - 1 : 0) * 20 + 10;
                        }
                    }

                    MouseArea{
                        id: itemIndicator
                        width: imageIndicator.width + 4
                        height: imageIndicator.height + 4
                        anchors.verticalCenter: itemRow.verticalCenter
                        propagateComposedEvents: (subNodes.count == 0)
                        onClicked: {
                            if(subNodes.count > 0){
                                var item = itemRect.getItemByID();
                                item.setExpanded(!item.isExpanded());
                            }else{
                                mouse.accepted = false;
                            }
                        }

                        Image {
                            id: imageIndicator
                            width: iconSize.width - 2
                            height: iconSize.height - 2
                            visible: subNodes.count > 0
                            anchors.centerIn: parent
                            source: expanded ? uriCollapseIcon : uriExpandIcon
                        }
                    }

                    // Icon
                    Item{
                        visible: (displayIcon != "")
                        width: imageIcon.width + 4
                        height: imageIcon.height + 4
                        anchors.verticalCenter: itemRow.verticalCenter

                        Image{
                            id: imageIcon
                            width: iconSize.width
                            height: iconSize.height
                            anchors.centerIn: parent
                            source: displayIcon
                        }
                    }

                    // Title
                    Text{
                        id: textTitle
                        anchors.verticalCenter: itemRow.verticalCenter
                        color: foregroundNormal
                        font: panel.font
                        text: displayText
                    }
                }
            }

            Item{
                visible: expanded
                width: repeaterSubNodes.implicitWidth
                height: repeaterSubNodes.implicitHeight
                Column{
                    id: repeaterSubNodes
                    Repeater {
                        model: subNodes
                        delegate: delegateItems
                    }
                }
            }
        }
    }

    function createItem(text, icon, parent){
        return new TreeItem.TreeItem(text, icon, parent);
    }

    function topLevelItem(index){
        return rootItem.childItem(index);
    }

    function indexOfTopLevelItem(item){
        return rootItem.indexOfChildItem(item);
    }

    function addTopLevelItem(item){
        rootItem.appendChild(item);
    }

    function takeTopLevelItem(item){
        rootItem.removeChild(indexOfItem(item));
    }

    function getCurrentItem(){
        return currentItem;
    }

    ListView{
        id: listView
        anchors.fill: parent
        model: listModel
        delegate: delegateRoot

        Component.onCompleted: {
            rootItem.setExpanded(true);
            listModel.append(rootItem);
        }
    }
}
