Ext.ns("Group");

Group.Index = Ext.extend(Desktop.App, {
    layout: 'fit',

    initComponent: function() {

        //setup store
        var store = new Ext.data.JsonStore({
            // store configs
            autoDestroy: true,
            url: 'groups.json',
            storeId: 'group_index',
            // reader configs
            root: 'data',
            fields: ['name', 'uri']
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
                }]
            }),
            viewConfig: {
                forceFit: true
            },
            sm: new Ext.grid.RowSelectionModel({
                singleSelect: true
            }),
            listeners: {
                rowclick: function(g, index) {
                    Desktop.workspace.getMainBar().showButton('edit', _this);
                },
                rowdblclick: function(g, index) {
                    var record = g.getStore().getAt(index);
                    Desktop.AppMgr.display('edit_view', record.get('uri'));
                }
            },
            scope: this
        });

        //setup mainBar
        var mainBar = [{
            text: 'View',
            itemId: 'view',
            iconCls: 'dt-icon-edit',
            hidden: true,
            handler: function() {
                this.fireEvent('edit')
            },
            scope: this
        }];

        //apply all components to this app instance
        Ext.apply(this, {
            items: grid,
            mainBar: mainBar
        });

        Group.Index.superclass.initComponent.call(this);
        
        this.on('render',
        function() {
            store.reload();
        });
    }
});

Desktop.AppMgr.registerApp(Group.Index, {
    title: 'My Groups',
    iconCls: 'dt-icon-group',
    appId: 'group_index',
    displayMenu: 'user',
    dockContainer: Desktop.EAST
});
