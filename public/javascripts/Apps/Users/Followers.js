Ext.ns("User");

User.Followers = Ext.extend(Desktop.App, {
  layout: 'fit',
  
  initComponent : function(){
    
    var ic = this.initialConfig; //configuration given to Desktop.App
    var _this = this;

    //setup store
    var store = new Ext.data.JsonStore({
        // store configs
        autoLoad: {params:{start: 0, limit: _this.pageSize}},
        restful: true,
        autoDestroy: true,
        url: 'users/' + ic.instanceId +'/followers.json',
        storeId: 'followers_index',
        // reader configs
        root: 'data',
        fields: ['id', 'name', 'description']
    });
  
    //setup grid
    
    var grid = new Ext.grid.GridPanel({
        store: store,
        colModel: new Ext.grid.ColumnModel({
            columns: [
              {
                  header: 'Name',
                  dataIndex: 'name'
              },
              {
                  header: 'Description',
                  dataIndex: 'description'
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
                _this.showButton('view');
            },
            rowdblclick: function(g, index) {
                var record = g.getStore().getAt(index);
                Desktop.AppMgr.display('community_view', record.get('id'), {title: record.get('name')});
            }
        },
        bbar: new Ext.PagingToolbar({
          pageSize: _this.pageSize,
          store: store
        })
    });

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
    }
    ];

    //apply all components to this app instance
    Ext.apply(this, {
        items: grid,
        tbar: toolbar
    });

    //call App initComponent
    User.Followers.superclass.initComponent.call(this);

    //event handlers
    this.on('view',
    function() {
        var record = grid.getSelectionModel().getSelected();
        Desktop.AppMgr.display('community_view', record.get('id'), {title: record.get('name')});
    });
  }
});

Desktop.AppMgr.registerApp(User.Followers, {
  title: 'Followers',
  iconCls: 'dt-icon-followers',
  appId: 'user_followers',
  dockContainer: Desktop.CENTER
});