Ext.ns("Community");

Community.View = Ext.extend(Desktop.App, {
	frame: false,
	autoScroll: true,
	layout: 'fit',
	initComponent: function(){
	
		var ic = this.initialConfig;

		//apply all components to this app instance
		Ext.apply(this, {
			autoLoad: {
				url: 'contexts/' + ic.instanceId,
				method: 'GET'
			}
		});
		
		Community.View.superclass.initComponent.call(this);
	}
});

Desktop.AppMgr.registerApp(Community.View, {
	title: 'Member View',
	appId: 'community_view',
	iconCls: 'dt-icon-community',
	dockContainer: Desktop.CENTER
});
