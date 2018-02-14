
var _TREE_ITEM_ID_MIN = 100;
var _TREE_ITEM_ID_INVALID = -1;
var _TREE_ITEM_ID_CURRENT = _TREE_ITEM_ID_MIN;

// ENUM: Selection Flags
var SF_None = 0;
var SF_Current = 1;
var SF_Selected = 2;

function TreeItem(text, icon, parent){

    var __allocateID = function(){
        return (_TREE_ITEM_ID_CURRENT++);
    };

    this.itemID = __allocateID();
    this.displayText = text;
    this.displayIcon = icon;

    this.expanded = false;
    this.selectionFlag = SF_None;

    this.parentNode = null;
    this.subNodes = [];

    if(parent){
        parent.appendChild(this);
    }

}

TreeItem.prototype = {
    constructor: TreeItem

    , __getItemFromModel: function(){
        var item = this, vPath = [];
        while(item){
            vPath.splice(0, 0, item.itemID);
            item = item.parentNode;
        }

        var model = listModel;
        for(var i = 0; i < vPath.length; i++){
            var bFound = false;
            for(var j = 0; j < model.count; j++){
                var node = model.get(j);
                if(vPath[i] === node.itemID){
                    if(i == vPath.length - 1){
                        return node;
                    }else{
                        model = node.subNodes;
                        bFound = true;
                        break;
                    }
                }
            }
            if(!bFound){
                // print("Error - Cannot follow the path")
                return null;
            }
        }
    }

    , level: function(){
        var level = 0, item = this;
        while(item.parentNode){
            item = item.parentNode
            level++;
        }
        return level;
    }
    , appendChild: function(item){
        if(item.parentNode){
            item.parentNode.removeChild(item);
        }
        item.parentNode = this;

        this.subNodes.push(item);

        var node = this.__getItemFromModel();
        if(node){
            node.subNodes.append(item);
        }
    }
    , insertChild: function(pos, item){
        if(item.parentNode){
            item.parentNode.removeChild(item);
        }
        item.parentNode = this;

        this.subNodes.splice(pos, 0, item);

        var node = this.__getItemFromModel();
        if(node){
            node.subNodes.insert(pos, item);
        }
    }
    , removeChild: function(item){
        var i = this.subNodes.indexOf(item);
        this.subNodes.splice(i, 1);
        item.parentNode = null;

        var currentSelectionFlag = item.getSelectionFlag();
        // 2018.2.13 Clear the flag of the selection when removing the current item
        item.setSelectionFlag(SF_None);
        // 2018.2.14 Select the next current item after removing the current item
        if(currentSelectionFlag === SF_Current){
            if(this.subNodes.length > 0){
                var nextCurrent = i;
                if(nextCurrent >= this.subNodes.length){
                    nextCurrent = this.subNodes.length - 1;
                }
                this.subNodes[nextCurrent].setSelectionFlag(SF_Current);
            }else{
                if(this.itemID !== rootItem.itemID) this.setSelectionFlag(SF_Current);
            }
        }


        var node = this.__getItemFromModel();
        if(node){
            node.subNodes.remove(i);
        }

    }
    , childItem: function(index){
        return this.subNodes[index];
    }
    , indexOfChildItem: function(item){
        for(var i = 0; i < this.subNodes.length; i++){
            if(this.subNodes[i].itemID === item.itemID){
                return i;
            }
        }
        return -1;
    }
    , childernCount: function(recursive){
        if(!recursive) recursive = false
        var count = this.subNodes.length;
        if(recursive){
            for(var i = 0; i < this.subNodes.length; i++){
                count += this.subNodes[i].childernCount(recursive);
            }
        }
        return count;
    }, parent: function(){
        return this.parentNode;
    }

    , setText: function(text){
        this.displayText = text;

        var node = this.__getItemFromModel();
        if(node){
            node.displayText = text;
        }
    }
    , text: function(){
        return this.displayText;
    }

    , setIcon: function(source){
        this.displayIcon = source;

        var node = this.__getItemFromModel();
        if(node){
            node.displayIcon = source;
        }
    }
    , icon: function(){
        return this.displayIcon;
    }

    , setExpanded: function(expanded){
        this.expanded = expanded;

        var node = this.__getItemFromModel();
        if(node){
            node.expanded = expanded;
        }
    }
    , isExpanded: function(){
        return this.expanded;
    }

    , setSelectionFlag: function(flag){
        this.selectionFlag = flag;
        if(flag === SF_Current){
            currentItem = this;
        }else{
            if(currentItem.itemID === this.itemID){
                currentItem = null;
            }
        }

        var node = this.__getItemFromModel();
        if(node){
            node.selectionFlag = flag;
        }
    }
    , getSelectionFlag: function(){
        return this.selectionFlag;
    }
}
