Ext.ns("User");

User.Index = Ext.extend(Desktop.App, {
    layout: 'fit',

    initComponent: function() {

        //setup store
        var store = new Ext.data.JsonStore({
            // store configs
            autoDestroy: true,
            url: 'users.json',
            storeId: 'user_index',
            // reader configs
            root: 'data',
            fields: ['name', 'uri',
            {
                name: 'created_at',
                type: 'date'
            }]
        });

        //setup grid
        var _this = this;
        var grid = new Ext.grid.GridPanel({
            store: store,
            colModel: new Ext.grid.ColumnModel({
                columns: [
                {
                    header: 'Name',
                    dataIndex: 'name'
                },
                {
                    header: 'Joined',
                    dataIndex: 'created_at',
                    xtype: 'datecolumn',
                    format: 'M d, Y'
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
                    Desktop.workspace.getMainBar().showButton('view', _this);
                },
                rowdblclick: function(g, index) {
                    var record = g.getStore().getAt(index);
                    Desktop.AppMgr.display('user_view', record.get('uri'));
                }
            },
            scope: this
        });

        //setup mainBar
        var mainBar = [{
            text: 'View',
            itemId: 'view',
            iconCls: 'dt-icon-view',
            hidden: true,
            handler: function() {
                this.fireEvent('view')
            },
            scope: this
        }];

        //apply all components to this app instance
        Ext.apply(this, {
            items: grid,
            mainBar: mainBar
        });

        User.Index.superclass.initComponent.call(this);
        
        this.on('render',
        function() {
            store.reload();
        });
    }
});

Desktop.AppMgr.registerApp(User.Index, {
    title: 'Community',
    iconCls: 'dt-icon-user',
    appId: 'user_index',
    displayMenu: 'public',
    dockContainer: Desktop.EAST
});
