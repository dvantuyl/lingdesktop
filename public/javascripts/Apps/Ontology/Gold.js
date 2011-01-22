Ext.ns("Ontology");

Ontology.Gold = Ext.extend(Desktop.App, {
    frame: false,
    autoScroll: false,
    layout: 'accordion',
    initComponent: function() {

        var sid = 'gold';
        var roots = [
        //{uri:'http://www.w3.org/2002/07/owl#Thing', title:'Root'},
        {
            localname: 'PartOfSpeechProperty',
            title: 'Part Of Speech Property'
        },
        {
            localname: 'MorphosyntacticProperty',
            title: 'Morphosyntactic Property'
        },
        {
            localname: 'PhoneticProperty',
            title: 'Phonetic Property'
        },
        {
            localname: 'MorphosemanticProperty',
            title: 'Morphosemantic Property'
        }
        ];

        var trees = [];
        for (var i = 0, len = roots.length; i < len; i++) {
            trees[i] = new Ontology.Tree({
                title: roots[i].title,
                sid: sid,
                localname: roots[i].localname
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

        Ontology.Gold.superclass.initComponent.call(this);

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
            this.hideButton('individuals');
            this.hideButton('expand');
            this.hideButton('view');
        },
        this);

        this.on('expand',
        function() {
            var node = this.getLayout().activeItem.getSelectionModel().getSelectedNode();
            var text = node.attributes.text;
            var sid = node.attributes.sid;
            var localname = node.attributes.localname;
            var roots = [{
                localname: localname,
                title: text
            }];

            //open tree in new ontology_nav
            Desktop.AppMgr.display(
            'ontology_nav',
            node.attributes.localname,
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

            //open tree in new ontology_nav
            Desktop.AppMgr.display(
            'ontology_class_view',
            node.attributes.localname,
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

Desktop.AppMgr.registerApp(Ontology.Gold, {
    title: 'GOLD Ontology',
    appId: 'ontology_gold',
    iconCls: 'dt-icon-owl',
    displayMenu: 'public',
    dockContainer: Desktop.EAST,
});