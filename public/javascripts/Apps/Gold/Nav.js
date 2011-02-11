Ext.ns("Ontology");

Ontology.Nav = Ext.extend(Desktop.App, {
    frame: false,
    autoScroll: false,
    layout: 'accordion',
    initComponent: function() {

        var ic = this.initialConfig;

        var trees = [];
        for (var i = 0, len = ic.roots.length; i < len; i++) {
            trees[i] = new Ontology.Tree({
                title: ic.roots[i].title,
                localname: ic.roots[i].localname,
                sid: ic.sid
            });
        }
        //setup toolbar
        var toolbar = [
        {
            text: 'View',
            itemId: 'view',
            iconCls: 'dt-icon-view',
            hidden: true,
            handler: function() {
                this.fireEvent('view')
            },
            scope: this
        },
        {
            text: 'Expand to Tab',
            itemId: 'expand',
            iconCls: 'dt-icon-add',
            hidden: true,
            handler: function() {
                this.fireEvent('expand')
            },
            scope: this
        },
        {
            text: 'List',
            itemId: 'individuals',
            iconCls: 'dt-icon-grid',
            hidden: true,
            handler: function() {
                this.fireEvent('individuals')
            },
            scope: this
        }
        ];

        //apply all components to this app instance
        Ext.apply(this, {
            tbar: toolbar,
            items: trees
        });

        Ontology.Nav.superclass.initComponent.call(this);

        //events here
        this.on('nodeclick',
        function(node, e) {
            if (node.leaf) {
                this.hideButton('expand');
            } else {
                this.showButton('expand');
            }

            this.showButton('individuals');
            this.showButton('view');
        },
        this);

        this.on('tree-deactivate',
        function() {
            this.hideButton('expand');
            this.hideButton('view');
            this.hideButton('individuals');
        },
        this);

        this.on('expand',
        function() {
            var node = this.getLayout().activeItem.getSelectionModel().getSelectedNode();
            var text = node.attributes.text;
            var sid = node.attributes.sid;
            var localname = node.attributes.localname;
            var uri = node.attributes.uri;
            var roots = [{
                localname: localname,
                uri: uri,
                title: text
            }];

            //open tree in new ontology_nav
            Desktop.AppMgr.display(
            'ontology_nav',
            localname,
            {
                sid: sid,
                title: text,
                roots: roots
            }
            );
        },
        this);

        this.on('view',
        function() {
            var node = this.getLayout().activeItem.getSelectionModel().getSelectedNode();
            var text = node.attributes.text;
            var sid = node.attributes.sid;
            var localname = node.attributes.localname;

            Desktop.AppMgr.display(
            'ontology_class_view',
            localname,
            {
                sid: sid,
                title: text
            }
            );
        },
        this);

        this.on('individuals',
        function() {
            var node = this.getLayout().activeItem.getSelectionModel().getSelectedNode();
            var text = node.attributes.text;
            var sid = node.attributes.sid;
            var localname = node.attributes.localname;

            Desktop.AppMgr.display(
            'ontology_individual_index',
            localname,
            {
                sid: sid,
                title: text
            }
            );
        });

    }
});

Desktop.AppMgr.registerApp(Ontology.Nav, {
    title: 'Ont Nav',
    appId: 'ontology_nav',
    iconCls: 'dt-icon-owl',
    dockContainer: Desktop.EAST,
});