Ext.ns("HumanLanguageVarieties");

HumanLanguageVarieties.View = Ext.extend(Desktop.App, {
	frame: false,
	autoScroll: true,
	layout: 'fit',
	initComponent: function(){
	
		var ic = this.initialConfig;

		//apply all components to this app instance
		Ext.apply(this, {
			autoLoad: {
				url: 'human_language_varieties/' + ic.instanceId,
				method: 'GET',
				params: {context_id: ic.contextId}
			}
		});
		
		HumanLanguageVarieties.View.superclass.initComponent.call(this);
	}
});

Desktop.AppMgr.registerApp(HumanLanguageVarieties.View, {
	title: 'Human_language_variety View',
	appId: 'human_language_varieties_view',
	iconCls: 'dt-icon-human_language_varieties',
	contextBar: true,
	controller: 'human_language_varieties',
	dockContainer: Desktop.CENTER
});