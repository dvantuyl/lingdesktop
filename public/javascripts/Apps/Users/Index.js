Ext.ns("User");

User.Index = Ext.extend(Desktop.App, {
    frame: false,
    autoScroll: false,
    layout: 'fit',

    initComponent: function() {

        //setup store
        var store = new Ext.data.JsonStore({
            // store configs
            autoLoad: {params:{start: 0, limit: _this.pageSize}},
            restful: true,
            autoDestroy: true,
            url: 'users.json',
            storeId: 'users_index',
            // reader configs
            root: 'data',
            fields: ['name', 'email', 'id', 'localname',
              { name: 'is_admin', type: 'boolean'},
              { name: 'last_login_at', type: 'date'},
              { name: 'created_at', type: 'date'}
            ]
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
                    header: 'Email',
                    dataIndex: 'email'
                },
                {
                    header: 'Admin?',
                    dataIndex: 'is_admin'
                },
                {
                    header: 'Created',
                    dataIndex: 'created_at',
                    xtype: 'datecolumn',
                    format: 'M d, Y'
                },
                {
                    header: 'Last Login',
                    dataIndex: 'last_login_at',
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
                    _this.showButton('edit');
                },
                rowdblclick: function(g, index) {
                    var record = g.getStore().getAt(index);
                    Desktop.AppMgr.display('user_form', record.get('id'), {title: record.get('name')});
                }
            },
            bbar: new Ext.PagingToolbar({
              pageSize: _this.pageSize,
              store: store
            }),
            scope: this
        });

        //setup toolbar
        var toolbar = [
        {
            text: 'New',
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

        //apply all components to this app instance
        Ext.apply(this, {
            items: grid,
            tbar: toolbar
        });

        //call App initComponent
        User.Index.superclass.initComponent.call(this);

        //event handlers
        this.on('new',
        function() {
            Desktop.AppMgr.display('user_form');
        });

        this.on('edit',
        function() {
            var record = grid.getSelectionModel().getSelected();
            Desktop.AppMgr.display('user_form', record.get('id'), {title: record.get('name')});
        });
    }
});

Desktop.AppMgr.registerApp(User.Index, {
    title: 'Users',
    iconCls: 'dt-icon-user',
    appId: 'user_index',
    displayMenu: 'admin',
    dockContainer: Desktop.CENTER
});
