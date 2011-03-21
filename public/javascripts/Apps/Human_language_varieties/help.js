Ext.ns("HumanLanguageVarieties");

HumanLanguageVarieties.Help = Ext.extend(Desktop.App, {
	frame: true,
	initComponent : function() {		
		//apply all components to this app instance
		Ext.apply(this, {
			autoLoad: {
				url: 'help/human_language_varieties',
				method: 'GET'
			}
		});
 		
 		HumanLanguageVarieties.Help.superclass.initComponent.call(this);
 	}
});

Desktop.AppMgr.registerApp(HumanLanguageVarieties.Help, {
	title: 'HumanLanguageVarieties Help',
	appId: 'human_language_varieties_help',
	iconCls: 'dt-icon-human_language_varieties',
	dockContainer: Desktop.CENTER,
	displayMenu: 'help'
});