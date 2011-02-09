Ext.ns("Termsets");

Termsets.View = Ext.extend(Desktop.App, {
	frame: false,
	autoScroll: true,
	layout: 'fit',
	initComponent: function(){
	
		var ic = this.initialConfig;

		//apply all components to this app instance
		Ext.apply(this, {
			autoLoad: {
				url: 'termsets/' + ic.instanceId,
				method: 'GET',
				params: {context_id: ic.contextId}
			}
		});
		
		Termsets.View.superclass.initComponent.call(this);
	}
});

Desktop.AppMgr.registerApp(Termsets.View, {
	title: 'Termsets View',
	appId: 'termsets_view',
	iconCls: 'dt-icon-term',
	dockContainer: Desktop.CENTER
});