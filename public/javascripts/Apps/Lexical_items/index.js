Ext.ns("LexicalItems");

LexicalItems.Index = Ext.extend(Desktop.App, {
    frame: false,
    autoScroll: false,
    layout: 'fit',
    initComponent: function() {


        //setup toolbar
        var toolbar = [
        {
            text: 'New',
            itemId: 'new',
            iconCls: 'dt-icon-add',
            handler: function() {
                this.fireEvent('new')
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
        
        var ic = this.initialConfig;

        //setup store
        var store = new Ext.data.JsonStore({
            // store configs
            autoDestroy: true,
            url: "lexical_items.json",
            // reader configs
            root: 'data',
            storeId: 'lexical_items_index',
            fields: ["rdfs:label", "rdfs:comment","rdf:type", "uri","localname"]
        });

        //setup grid
        var _this = this;
        var grid = new Ext.grid.GridPanel({
            store: store,
            stripeRows: true,
            colModel: new Ext.grid.ColumnModel({
                columns: [
                    {
                        header: 'Name',
                        dataIndex: "rdfs:label"
                    },{
                        header: 'Description',
                        dataIndex: "rdfs:comment"
                    }
                ]
            }),
            viewConfig: {
                forceFit: true
            },
            sm: new Ext.grid.RowSelectionModel({
                singleSelect: true
            }),
            listeners: {
                rowclick: function(g, index) {
                    _this.showButton('edit');
                },
                rowdblclick: function(g, index) {
                    _this.fireEvent('edit');
                }
            },
            scope: this
        });

        //apply all components to this app instance
        Ext.apply(this, {
            tbar: toolbar,
            items: grid
        });

        LexicalItems.Index.superclass.initComponent.call(this);

        //event handlers
        this.on('new',
        function() {

            Desktop.AppMgr.display(
            'lexical_items_edit'
            //give tree's root node so that the form can refresh the entire tree on save
            );
        });

        this.on('edit',
        function() {
          var record = grid.getSelectionModel().getSelected();
          var label = record.get("rdfs:label");
          var localname = record.get("localname");

          Desktop.AppMgr.display('lexical_items_edit', localname, {
              title: label
          });

        });
        
        this.on('render',
        function() {
            store.reload();
        });

        Desktop.AppMgr.display('lexical_items_help');
    }
});

Desktop.AppMgr.registerApp(LexicalItems.Index, {
    title: 'Lexical Items',
    iconCls: 'dt-icon-lexical_items',
    appId: 'lexical_items_index',
    dockContainer: Desktop.WEST
});
