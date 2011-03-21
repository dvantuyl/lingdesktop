Ext.ns("Ontology.Class");

Ontology.Class.View = Ext.extend(Desktop.App, {
	frame: false,
	autoScroll: true,
	layout: 'fit',
	initComponent: function(){
	
		var ic = this.initialConfig;
		
		//apply all components to this app instance
		Ext.apply(this, {
			tbar : toolbar,
			autoLoad: {
				url: 'gold/' + ic.instanceId,
				method: 'GET',
				params: {context_id: "lingdesktop"}
			}
		});
		
		Ontology.Class.View.superclass.initComponent.call(this);
	}
});

Desktop.AppMgr.registerApp(Ontology.Class.View, {
	title: 'Class View',
	appId: 'ontology_class_view',
	iconCls: 'dt-icon-owl',
	dockContainer: Desktop.CENTER
});
