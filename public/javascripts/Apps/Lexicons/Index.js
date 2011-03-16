Ext.ns("Lexicons");

Lexicons.Index = Ext.extend(Desktop.App, {
    frame: false,
    autoScroll: false,
    layout: 'fit',
    
    initComponent: function() {

        var ic = this.initialConfig;
        var _this = this;

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
        
        //setup store
        var store = new Ext.data.JsonStore({
            // store configs
            autoLoad: {params:{start: 0, limit: _this.pageSize}},
            restful: true,
            autoDestroy: true,
            url: "lexicons.json",
            // reader configs
            root: 'data',
            storeId: 'lexicons_index',
            fields: ["rdfs:label", "rdfs:comment","rdf:type", "uri","localname"]
        });

        //setup grid
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

        Lexicons.Index.superclass.initComponent.call(this);

        //event handlers
        this.on('new',
        function() {

            Desktop.AppMgr.display(
            'lexicons_edit'
            //give tree's root node so that the form can refresh the entire tree on save
            );
        });

        this.on('edit',
        function() {
          var record = grid.getSelectionModel().getSelected();
          var label = record.get("rdfs:label");
          var localname = record.get("localname");

          Desktop.AppMgr.display('lexicons_edit', localname, {
              title: label
          });

        });

        Desktop.AppMgr.display('lexicons_help');
    }
});

Desktop.AppMgr.registerApp(Lexicons.Index, {
    title: 'Lexicons',
    iconCls: 'dt-icon-lexicons',
    appId: 'lexicons_index',
    displayMenu: 'user',
    dockContainer: Desktop.WEST
});
