Ext.ns("Community");

Community.Index = Ext.extend(Desktop.App, {
  layout: 'fit',
  
  initComponent : function(){
    
    //setup store
    var store = new Ext.data.JsonStore({
        // store configs
        autoDestroy: true,
        url: 'contexts.json',
        storeId: 'community_index',
        // reader configs
        root: 'data',
        fields: ['id', 'name', 'description', 'is_group']
    });
  
    //setup grid
    var _this = this;
    var grid = new Ext.grid.GridPanel({
        enableDrag : true,
        ddGroup : 'community',
        store: store,
        colModel: new Ext.grid.ColumnModel({
            columns: [
              { 
                width: 10,
                dataIndex: 'is_group',
                renderer: function(val){
                  if(val){
                    return '<img src="' + '/images/icons/group.png' + '">';
                  }else{
                    return '<img src="' + '/images/icons/user.png' + '">';
                  }
                }
              },
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
        }
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
    Community.Index.superclass.initComponent.call(this);

    //event handlers
    this.on('view',
    function() {
        var record = grid.getSelectionModel().getSelected();
        Desktop.AppMgr.display('community_view', record.get('id'), {title: record.get('name')});
    });

    this.on('render',
    function() {
        store.reload();
    });
  }
});

Desktop.AppMgr.registerApp(Community.Index, {
  title: 'Community',
  iconCls: 'dt-icon-community',
  appId: 'community_index',
  dockContainer: Desktop.EAST
});