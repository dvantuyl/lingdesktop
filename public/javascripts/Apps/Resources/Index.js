Ext.ns("Resource");

Resource.Index = Ext.extend(Desktop.App, {
  frame: false,
  autoScroll: false,
  layout: 'fit',

    initComponent: function() {
        var ic = this.initialConfig;
        var _this = this;

        var index_path = (ic.index_path ? ic.index_path : ic.instanceId);

        //setup store
        var store = new Ext.data.JsonStore({
            // store configs
            autoLoad: {params:{start: 0, limit: _this.pageSize}},
            restful: true,
            autoDestroy: true,
            url: index_path + ".json?context_id=" + ic.contextId,
            // reader configs
            root: 'data',
            fields: ["rdfs:label", "rdfs:comment","rdf:type", "uri","localname"]
        });

        //setup grid
        var _this = this;
        var grid = new Ext.grid.GridPanel({
            enableDrag: true,
            ddGroup: 'resource',
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
                    _this.showButton('view');
                },
                rowdblclick: function(g, index) {
                    var record = g.getStore().getAt(index);
                    var label = record.get('rdfs:label');
                    //var sid = record.get('sid');
                    var localname = record.get('localname');

                    Desktop.AppMgr.display(
                        ic.instanceId + '_view',
                        localname,
                        {
                            //sid: sid,
                            title: label,
                            contextId : ic.contextId
                        }
                    );
                }
            },
            bbar: new Ext.PagingToolbar({
              pageSize: _this.pageSize,
              store: store
            }),
            scope: this
        });

        //setup toolbar
        var toolbar = [{
            text: 'View',
            itemId: 'view',
            iconCls: 'dt-icon-view',
            hidden: true,
            handler: function() {
                this.fireEvent('view')
            },    
            scope: this
        }    ,
                        '->',
                        new Ext.ux.form.SearchField({
                          store: store,
                          width: 100
                        })];

        //apply all components to this app instance
        Ext.apply(this, {
            items: grid,
            tbar: toolbar
        });

        //call App initComponent
        Resource.Index.superclass.initComponent.call(this);

        //event handlers
        this.on('view',
        function() {
            var record = grid.getSelectionModel().getSelected();
            var label = record.get("rdfs:label");
            
            //var sid = record.get('sid');
            var localname = record.get("localname");

            Desktop.AppMgr.display(
                ic.instanceId + '_view',
                localname,
                {
                    //sid: sid,
                    title: label,
                    contextId : ic.contextId
                }
            );
        },
        this);
    }
});

Desktop.AppMgr.registerApp(Resource.Index, {
    title: 'Resources',
    iconCls: 'dt-icon-grid',
    appId: 'resource_index',
    dockContainer: Desktop.SOUTH
});
