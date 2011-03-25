Ext.ns("Lexicons");

Lexicons.View = Ext.extend(Desktop.App, {
	frame: false,
	autoScroll: true,
	layout: 'fit',
	initComponent: function(){
	
		var ic = this.initialConfig;

		//apply all components to this app instance
		Ext.apply(this, {
			autoLoad: {
				url: 'lexicons/' + ic.instanceId,
				method: 'GET',
				params: {context_id: ic.contextId}
			}
		});
		
		Desktop.AppMgr.display('lexical_items_index', ic.instanceId, {title: 'Lexical Items', context_id: ic.contextId});
		
		Lexicons.View.superclass.initComponent.call(this);
	}
});

Desktop.AppMgr.registerApp(Lexicons.View, {
	title: 'Lexicon View',
	appId: 'lexicons_view',
	iconCls: 'dt-icon-lexicons',
	contextBar: true,
	controller: 'lexicons',
	dockContainer: Desktop.CENTER
});