Ext.ns("Ontology.Class");

Ontology.Class.View = Ext.extend(Desktop.App, {
	frame: false,
	autoScroll: true,
	layout: 'fit',
	initComponent: function(){
	
		var ic = this.initialConfig;
		
		//setup toolbar 
		var toolbar = [
			{text: 'List', iconCls: 'dt-icon-grid', handler:function(){this.fireEvent('individuals')}, scope: this}
		];
		
		//apply all components to this app instance
		Ext.apply(this, {
			tbar : toolbar,
			autoLoad: {
				url: 'gold/' + ic.instanceId,
				method: 'GET',
				params: {sid: ic.sid}
			}
		});
		
		Ontology.Class.View.superclass.initComponent.call(this);
		
		this.on('individuals', function(){
			Desktop.AppMgr.display(
				'ontology_individual_index', 
				ic.instanceId, 
				{sid: ic.sid, title: ic.title}
			);		
		});
		
		this.fireEvent('individuals');
	}
});

Desktop.AppMgr.registerApp(Ontology.Class.View, {
	title: 'Class View',
	appId: 'ontology_class_view',
	iconCls: 'dt-icon-owl',
	dockContainer: Desktop.CENTER
});
