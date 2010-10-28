Ext.ns("Ontology.Individual");

Ontology.Individual.Index = Ext.extend(Desktop.App, {
	layout: 'fit',
	
	initComponent : function() {		
	   var ic = this.initialConfig;
	   
	   //setup store
	   var store = new Ext.data.JsonStore({
		    // store configs
		    autoDestroy: true,
		    url: 'gold/'+ic.instanceId+'.json?get=individuals&sid=' + ic.sid,
		    // reader configs
		    root: 'data',
		    fields: ['rdf_type', 'sid', 'uri', 'label', 'localname']
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
		            {header: 'Label', dataIndex: 'label'},
					{header: 'URI', dataIndex: 'uri'}
		        ]
		    }),
		    viewConfig: {
		        forceFit: true
		    },
		    sm: new Ext.grid.RowSelectionModel({singleSelect:true}),
			listeners: {
				rowclick: function(g, index){
					Desktop.workspace.getMainBar().showButton('view', _this);
				},
				rowdblclick : function(g, index){
					var record = g.getStore().getAt(index);
					var label = record.get('label');
					var sid = record.get('sid');
					var localname = record.get('localname');
			
					Desktop.AppMgr.display(
						'ontology_class_view', 
						localname, 
						{sid: sid, title: label}
					);
				}
			},
			scope: this
		});
		
		//setup mainBar 
		var mainBar = [
			{text: 'View', itemId:'view', iconCls: 'dt-icon-view', hidden: true, handler:function(){this.fireEvent('view')}, scope: this}
		];
		
		//apply all components to this app instance
 		Ext.apply(this, {
 			items : grid,
			mainBar : mainBar
 		});
 		
		//call App initComponent
		Ontology.Individual.Index.superclass.initComponent.call(this);
		
		//event handlers
		this.on('view', function(){
			var record = grid.getSelectionModel().getSelected();
			var label = record.get('label');
			var sid = record.get('sid');
			var localname = record.get('localname');
	
			Desktop.AppMgr.display(
				'ontology_class_view', 
				localname, 
				{sid: sid, title: label}
			);
		},this);
		
		this.on('render',function(){
			store.reload();
		});
 	}
});

Desktop.AppMgr.registerApp(Ontology.Individual.Index, {
	title: 'Individuals',
	iconCls: 'dt-icon-grid',
	appId: 'ontology_individual_index',
	dockContainer: Desktop.SOUTH
});
