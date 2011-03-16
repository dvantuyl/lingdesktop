Ext.ns("Community");

Community.Index = Ext.extend(Desktop.App, {
  layout: 'fit',
  frame: false,
  autoScroll: false,
  
  initComponent : function(){
    
    var _this = this;
    
    //setup store
    var store = new Ext.data.JsonStore({
        // store configs
        autoLoad: {params:{start: 0, limit: _this.pageSize}},
        restful: true,
        autoDestroy: true,
        url: 'contexts.json',
        storeId: 'community_index',
        // reader configs
        root: 'data',
        fields: ['id', 'name', 'description', 'is_group']
    });
  
    //setup grid
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
        },
        bbar: new Ext.PagingToolbar({
          pageSize: _this.pageSize,
          store: store
        })
    });

    //setup toolbar
    var toolbar = {
      height: 25,
      items:[{
        text: 'View',
        itemId: 'view',
        iconCls: 'dt-icon-view',
        hidden: true,
        handler: function() {
            this.fireEvent('view')
        },
        scope: this
      }]
    };

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
  }
});

Desktop.AppMgr.registerApp(Community.Index, {
  title: 'Community',
  iconCls: 'dt-icon-community',
  appId: 'community_index',
  dockContainer: Desktop.EAST
});