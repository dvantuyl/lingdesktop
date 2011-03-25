Ext.ns("LexicalizedConcepts");

LexicalizedConcepts.Index = Ext.extend(Desktop.App, {
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
           url: "lexicalized_concepts.json",
           // reader configs
           root: 'data',
           storeId: 'lexicalized_concepts_index',
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
            ddGroup : 'hasMeaning',
            enableDragDrop :true,
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
                    _this.fireEvent('view');
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

        LexicalizedConcepts.Index.superclass.initComponent.call(this);

        //event handlers
        this.on('new',
        function() {

            Desktop.AppMgr.display(
            'lexicalized_concepts_edit'
            );
        });

        this.on('edit',
        function() {
          var record = grid.getSelectionModel().getSelected();
          var label = record.get("rdfs:label");
          var localname = record.get("localname");

          Desktop.AppMgr.display('lexicalized_concepts_edit', localname, {
              title: label + ' - Edit'
          });

        });
        
        this.on('view',
          function() {
            var record = grid.getSelectionModel().getSelected();
            var label = record.get("rdfs:label");
            var localname = record.get("localname");
            
            Desktop.AppMgr.display(
                'lexicalized_concepts_view',
                localname,
                {
                    title : label,
                    contextId : ic.contextId
                }
            );
          }
        );

        Desktop.AppMgr.display('lexicalized_concepts_help');
    }
});

Desktop.AppMgr.registerApp(LexicalizedConcepts.Index, {
    title: 'LexicalizedConcepts',
    iconCls: 'dt-icon-lexicalized_concepts',
    appId: 'lexicalized_concepts_index',
    displayMenu: 'user',
    dockContainer: Desktop.WEST
});
