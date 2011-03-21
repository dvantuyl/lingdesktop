Ext.ns("LexicalItems");

LexicalItems.Index = Ext.extend(Desktop.App, {
    frame: false,
    autoScroll: false,
    layout: 'fit',
    initComponent: function() {

       var ic = this.initialConfig;
       var _this = this;

       //setup store
       var store = new Ext.data.JsonStore({
           // store configs
           autoLoad: {params:{start: 0, limit: _this.pageSize}},
           restful: true,
           autoDestroy: true,
           url: "lexicons/" + ic.instanceId + "/lexical_items.json",
           // reader configs
           root: 'data',
           storeId: 'lexical_items_index',
           fields: ["rdfs:label", "rdfs:comment","rdf:type", "uri","localname"]
       });

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
        },
          '->',
          new Ext.ux.form.SearchField({
            store: store,
            width: 100
          })
        ];

        //setup grid
        var grid = new Ext.grid.GridPanel({
            store: store,
            stripeRows: true,
            colModel: new Ext.grid.ColumnModel({
                columns: [
                    {
                        header: 'Headword',
                        dataIndex: "rdfs:label"
                    },{
                        header: 'Notes',
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
            bbar: new Ext.PagingToolbar({
              pageSize: _this.pageSize,
              store: store
            }),
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
            'lexical_items_edit',
            null,
            {lexicon_id : ic.instanceId}
            );
        });

        this.on('edit',
        function() {
          var record = grid.getSelectionModel().getSelected();
          var label = record.get("rdfs:label");
          var localname = record.get("localname");

          Desktop.AppMgr.display('lexical_items_edit', localname, {
              title: label,
              lexicon_id: ic.instanceId
          });

        });
    }
});

Desktop.AppMgr.registerApp(LexicalItems.Index, {
    title: 'LexicalItems',
    iconCls: 'dt-icon-lexicons',
    appId: 'lexical_items_index',
    dockContainer: Desktop.WEST
});
