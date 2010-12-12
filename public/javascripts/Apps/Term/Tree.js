Ext.ns("Term");

Term.Tree = Ext.extend(Ext.tree.TreePanel, {
    rootVisible: false,
    autoScroll: true,
    enableDrag: true,
    //ddGroup : 'resource',
    initComponent: function() {
        var ic = this.initialConfig;

        //set dummy root
        var root = new Ext.tree.AsyncTreeNode({
            text: 'Invisible Root',
            draggable: false,
            sid: ic.sid
        });

        //init tree loader
        var loader = new Ext.tree.TreeLoader({
            url: 'termsets.json',
            requestMethod: 'GET'
        });

        var edit_btn = {
            xtype: 'button',
            text: 'Edit',
            handler: function() {
                var node = this.getSelectionModel().getSelectedNode();
                var text = node.attributes.text;
                //var sid = node.attributes.sid;
                var rdf_type = node.attributes.localname;

                //open tree in new term_nav
                Desktop.AppMgr.display(
                'term_set_form',
                node.attributes.localname,
                {
                    title: text
                }
                );

                //hide context menu
                node.getOwnerTree().contextMenu.hide();
            },
            scope: this
        }

        //right click menu
        var contextMenu = new Ext.menu.Menu({
            items: [edit_btn]
        });

        Ext.apply(this, {
            contextMenu: contextMenu,
            root: root,
            loader: loader
        });

        Term.Tree.superclass.initComponent.call(this);

        //set the tree base params to the node attributes
        loader.on("beforeload",
        function(treeLoader, node) {
            if (node.attributes["rdf:type"] == 'http://purl.org/linguistics/gold/Termset') {
                treeLoader.url = 'termsets/' + node.attributes.localname + '/terms.json';
            }
            else {
                treeLoader.url = 'termsets.json';
            }
            //treeLoader.baseParams.sid = node.attributes.sid;
        },
        this);

        //on right click
        this.on("contextmenu",
        function(node, e) {
            // Register the context node with the menu so that a Menu Item's handler function can access
            // it via its parentMenu property.
            node.select();
            var c = node.getOwnerTree().contextMenu;
            c.contextNode = node;
            c.showAt(e.getXY());
        },
        this);

        this.on('click',
        function(node, e) {
            this.ownerCt.fireEvent('nodeclick', node, e);
        },
        this);

        this.on('dblclick',
        function(node, e) {
            this.ownerCt.fireEvent('edit', node, e);
        },
        this);

        this.on('containerclick',
        function() {
            this.ownerCt.fireEvent('containerclick');
        });

        this.on('deactivate',
        function() {
            this.ownerCt.fireEvent('tree-deactivate');
        },
        this);
    }
});

