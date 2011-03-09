Ext.ns("Terms");

Terms.Help = Ext.extend(Desktop.App, {
	frame: true,
	initComponent : function() {		
		//apply all components to this app instance
		Ext.apply(this, {
			autoLoad: {
				url: 'help/terms',
				method: 'GET'
			}
		});
 		
 		Terms.Help.superclass.initComponent.call(this);
 	}
});

Desktop.AppMgr.registerApp(Terms.Help, {
	title: 'Terms Help',
	appId: 'terms_help',
	iconCls: 'dt-icon-term',
	dockContainer: Desktop.CENTER,
	displayMenu: 'help'
});