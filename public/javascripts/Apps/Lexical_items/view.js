Ext.ns("LexicalItems");

LexicalItems.View = Ext.extend(Desktop.App, {
	frame: false,
	autoScroll: true,
	layout: 'fit',
	initComponent: function(){
	
		var ic = this.initialConfig;

		//apply all components to this app instance
		Ext.apply(this, {
			autoLoad: {
				url: 'lexical_items/' + ic.instanceId,
				method: 'GET',
				params: {context_id: ic.contextId}
			}
		});
		
		
		
		LexicalItems.View.superclass.initComponent.call(this);
		
	}
});

Desktop.AppMgr.registerApp(LexicalItems.View, {
	title: 'Lexical_item View',
	appId: 'lexical_items_view',
	iconCls: 'dt-icon-lexicons',
	contextBar: true,
	controller: 'lexical_items',
	dockContainer: Desktop.CENTER
});