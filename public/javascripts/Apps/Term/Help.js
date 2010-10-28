Ext.ns("Termset");

Termset.Help = Ext.extend(Desktop.App, {
	frame: true,
	initComponent : function() {		
		//apply all components to this app instance
		Ext.apply(this, {
			autoLoad: {
				url: 'help/termset',
				method: 'GET'
			}
		});
 		
 		Termset.Help.superclass.initComponent.call(this);
 	}
});

Desktop.AppMgr.registerApp(Termset.Help, {
	title: 'Help',
	appId: 'termset_help',
	iconCls: 'dt-icon-term',
	dockContainer: Desktop.CENTER,
	displayMenu: 'help'
});