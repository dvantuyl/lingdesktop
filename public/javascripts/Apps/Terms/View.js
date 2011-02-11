Ext.ns("Term");

Term.View = Ext.extend(Desktop.App, {
	frame: false,
	autoScroll: true,
	layout: 'fit',
	initComponent: function(){
	
		var ic = this.initialConfig;

		//apply all components to this app instance
		Ext.apply(this, {
			autoLoad: {
				url: 'terms/' + ic.instanceId,
				method: 'GET',
				params: {context_id: ic.contextId}
			}
		});
		
		Term.View.superclass.initComponent.call(this);
	}
});

Desktop.AppMgr.registerApp(Term.View, {
	title: 'term View',
	appId: 'terms_view',
	iconCls: 'dt-icon-term',
	contextBar: true,
	controller: 'terms',
	dockContainer: Desktop.CENTER
});