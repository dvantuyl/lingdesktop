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
		
		// display current user's lexical items if in context of current user otherwise display other contexts lexical items
		var current_user = Desktop.workspace.getCurrentUser();
		if(current_user.context_id && current_user.context_id == ic.contextId){
		  Desktop.AppMgr.display('lexical_items_index', ic.instanceId, {title: 'Lexical Items'});
		}else{
		  Desktop.AppMgr.display('resource_index', 'lexical_items', {contextId: ic.contextId, index_path: 'lexicons/' + ic.instanceId + '/lexical_items', title: 'Lexical Items'});
		}
		
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