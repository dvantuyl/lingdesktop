Ext.ns("LexicalizedConcepts");

LexicalizedConcepts.View = Ext.extend(Desktop.App, {
	frame: false,
	autoScroll: true,
	layout: 'fit',
	initComponent: function(){
	
		var ic = this.initialConfig;

		//apply all components to this app instance
		Ext.apply(this, {
			autoLoad: {
				url: 'lexicalized_concepts/' + ic.instanceId,
				method: 'GET',
				params: {context_id: ic.contextId}
			}
		});
		
		LexicalizedConcepts.View.superclass.initComponent.call(this);
	}
});

Desktop.AppMgr.registerApp(LexicalizedConcepts.View, {
	title: 'Lexicalized_concept View',
	appId: 'lexicalized_concepts_view',
	iconCls: 'dt-icon-lexicalized_concepts',
	contextBar: true,
	controller: 'lexicalized_concepts',
	dockContainer: Desktop.CENTER
});