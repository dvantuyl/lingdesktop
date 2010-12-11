Ext.ns("Term");

Term.Nav = Ext.extend(Desktop.App, {
    frame: false,
    autoScroll: false,
    layout: 'fit',
    initComponent: function() {

        var tree = new Term.Tree();

        //setup mainBar
        var mainBar = [
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
            mainBar: mainBar,
            items: tree
        });

        Term.Nav.superclass.initComponent.call(this);

        //event handlers
        this.on('new_termset',
        function() {
            Desktop.AppMgr.display(
            'term_set_form',
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

            if (selected && selected.attributes.rdf_type == 'http://purl.org/linguistics/gold/Term') {
                node = selected.parentNode;
            } else {
                node = selected
            }

            Desktop.AppMgr.display(
            'term_form',
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

            if (selected.attributes.rdf_type == 'http://purl.org/linguistics/gold/TermSet') {
                Desktop.AppMgr.display('term_set_form', selected.attributes.localname, {
                    title: selected.attributes.label,
                    node: tree.getRootNode()
                    //give tree's root node so that the form can refresh the entire tree on save
                });
            } else {
                Desktop.AppMgr.display('term_form', selected.attributes.localname, {
                    title: selected.attributes.label,
                    node: selected.parentNode
                    //give tree's root node so that the form can refresh the entire tree on save
                });
            }

        });

        this.on('nodeclick',
        function(node, e) {
            Desktop.workspace.getMainBar().showButton('edit', this);
            Desktop.workspace.getMainBar().showButton('new_term', this);
        });
        this.on('containerclick',
        function() {
            var selected = tree.getSelectionModel().getSelectedNode();
            if (!selected) {
                Desktop.workspace.getMainBar().hideButton('edit', this);
                Desktop.workspace.getMainBar().hideButton('new_term', this);
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
