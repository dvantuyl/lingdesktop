Ext.ns("LexicalizedConcepts");

LexicalizedConcepts.Help = Ext.extend(Desktop.App, {
	frame: true,
	initComponent : function() {		
		//apply all components to this app instance
		Ext.apply(this, {
			autoLoad: {
				url: 'help/lexicalized_concepts',
				method: 'GET'
			}
		});
 		
 		LexicalizedConcepts.Help.superclass.initComponent.call(this);
 	}
});

Desktop.AppMgr.registerApp(LexicalizedConcepts.Help, {
	title: 'LexicalizedConcepts Help',
	appId: 'lexicalized_concepts_help',
	iconCls: 'dt-icon-lexicalized_concepts',
	dockContainer: Desktop.CENTER,
	displayMenu: 'help'
});