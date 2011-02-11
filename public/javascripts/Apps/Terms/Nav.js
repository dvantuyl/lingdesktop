Ext.ns("Term");

Term.Nav = Ext.extend(Desktop.App, {
    frame: false,
    autoScroll: false,
    layout: 'fit',
    initComponent: function() {

        var tree = new Term.Tree();

        //setup toolbar
        var toolbar = [
        {
            text: 'New Termset',
            iconCls: 'dt-icon-add',
            handler: function() {
                this.fireEvent('new_termset')
            },
            scope: this
        },
        {
            text: 'New Term',
            itemId: 'new_term',
            iconCls: 'dt-icon-add',
            hidden: true,
            handler: function() {
                this.fireEvent('new_term')
            },
            scope: this
        },
        {
            text: 'Edit',
            itemId: 'edit',
            iconCls: 'dt-icon-edit',
            hidden: true,
            handler: function() {
                this.fireEvent('edit')
            },
            scope: this
        }
        ];

        //apply all components to this app instance
        Ext.apply(this, {
            tbar: toolbar,
            items: tree
        });

        Term.Nav.superclass.initComponent.call(this);

        //event handlers
        this.on('new_termset',
        function() {
            Desktop.AppMgr.display(
            'termsets_edit',
            null,
            {
                node: tree.getRootNode()
            }
            //give tree's root node so that the form can refresh the entire tree on save
            );
        });

        this.on('new_term',
        function() {

            var selected = tree.getSelectionModel().getSelectedNode();
            var node = null;
            
            
            if (selected && selected.attributes["rdf:type"] == 'http://purl.org/linguistics/gold/Term') {
                node = selected.parentNode;
            } else {
                node = selected
            }

            Desktop.AppMgr.display(
            'terms_edit',
            null,
            {
                node: node
            }
            //give tree's root node so that the form can refresh the entire tree on save
            );
        });

        this.on('edit',
        function(node, e) {
            var selected = tree.getSelectionModel().getSelectedNode();
            if (selected.attributes["rdf:type"] == 'http://purl.org/linguistics/gold/Termset') {
                Desktop.AppMgr.display('termsets_edit', selected.attributes.localname, {
                    title: selected.attributes["rdfs:label"],
                    node: tree.getRootNode()
                    //give tree's root node so that the form can refresh the entire tree on save
                });
            } else {
                Desktop.AppMgr.display('terms_edit', selected.attributes.localname, {
                    title: selected.attributes["rdfs:label"],
                    node: selected.parentNode
                    //give tree's root node so that the form can refresh the entire tree on save
                });
            }

        });

        this.on('nodeclick',
        function(node, e) {
            this.showButton('edit');
            this.showButton('new_term');
        });
        this.on('containerclick',
        function() {
            var selected = tree.getSelectionModel().getSelectedNode();
            if (!selected) {
                this.hideButton('edit');
                this.hideButton('new_term');
            }
        });

        Desktop.AppMgr.display('termset_help');
    }
});

Desktop.AppMgr.registerApp(Term.Nav, {
    title: 'Termset Navigator',
    iconCls: 'dt-icon-term',
    appId: 'term_nav',
    displayMenu: 'user',
    dockContainer: Desktop.WEST
});
