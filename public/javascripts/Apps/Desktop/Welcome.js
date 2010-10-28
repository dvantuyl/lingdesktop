Ext.ns("Desktop");

Desktop.Welcome = Ext.extend(Desktop.App, {
	frame: true,
	initComponent : function() {		
		
 		//apply all components to this app instance
		Ext.apply(this, {
			autoLoad: {
				url: 'help/welcome',
				method: 'GET'
			}
		});
 		
 		Desktop.Welcome.superclass.initComponent.call(this);
 	}
});

Desktop.AppMgr.registerApp(Desktop.Welcome, {
	title: 'Welcome',
	appId: 'desktop_welcome',
	iconCls: 'dt-icon-sparql',
	dockContainer: Desktop.CENTER,
	displayMenu: 'help'
});