Ext.ns("LexicalItems");

LexicalItems.Help = Ext.extend(Desktop.App, {
	frame: true,
	initComponent : function() {		
		//apply all components to this app instance
		Ext.apply(this, {
			autoLoad: {
				url: 'help/lexical_items',
				method: 'GET'
			}
		});
 		
 		LexicalItems.Help.superclass.initComponent.call(this);
 	}
});

Desktop.AppMgr.registerApp(LexicalItems.Help, {
	title: 'LexicalItems Help',
	appId: 'lexical_items_help',
	iconCls: 'dt-icon-lexicons',
	dockContainer: Desktop.CENTER,
	displayMenu: 'help'
});