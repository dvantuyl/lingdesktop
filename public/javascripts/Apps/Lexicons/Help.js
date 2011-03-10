Ext.ns("Lexicons");

Lexicons.Help = Ext.extend(Desktop.App, {
	frame: true,
	initComponent : function() {		
		//apply all components to this app instance
		Ext.apply(this, {
			autoLoad: {
				url: 'help/lexicons',
				method: 'GET'
			}
		});
 		
 		Terms.Help.superclass.initComponent.call(this);
 	}
});

Desktop.AppMgr.registerApp(Lexicons.Help, {
	title: 'Lexicons Help',
	appId: 'lexicons_help',
	iconCls: 'dt-icon-lexicons',
	dockContainer: Desktop.CENTER,
	displayMenu: 'help'
});