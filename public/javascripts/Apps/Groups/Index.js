Ext.ns("Groups");

Groups.Index = Ext.extend(Desktop.App, {
  layout: 'fit',
  
  initComponent : function(){
    
    var ic = this.initialConfig; //configuration given to Desktop.App
    var url = 'groups.json'
    
    if(ic.instanceId){
      url = 'users/' + ic.instanceId +'/groups.json'
    }
    
    //setup store
    var store = new Ext.data.JsonStore({
        // store configs
        autoDestroy: true,
        url: url,
        storeId: 'groups_index',
        // reader configs
        root: 'data',
        fields: ['id', 'name', 'description']
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
                _this.showButton('edit');
            },
            rowdblclick: function(g, index) {
                var record = g.getStore().getAt(index);
                Desktop.AppMgr.display('groups_form', record.get('id'), {title: record.get('name')});
            }
        }
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
    Groups.Index.superclass.initComponent.call(this);

    //event handlers
    this.on('new',
    function() {
        Desktop.AppMgr.display('groups_form');
    });

    this.on('edit',
    function() {
        var record = grid.getSelectionModel().getSelected();
        Desktop.AppMgr.display('groups_form', record.get('id'), {title: record.get('name')});
    });

    this.on('render',
    function() {
        store.reload();
    });
  }
});

Desktop.AppMgr.registerApp(Groups.Index, {
  title: 'My Groups',
  iconCls: 'dt-icon-groups',
  appId: 'groups_index',
  dockContainer: Desktop.CENTER
});