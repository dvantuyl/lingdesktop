Ext.ns("<%= controller_class_name %>");

<%= controller_class_name %>.View = Ext.extend(Desktop.App, {
	frame: false,
	autoScroll: true,
	layout: 'fit',
	initComponent: function(){
	
		var ic = this.initialConfig;

		//apply all components to this app instance
		Ext.apply(this, {
			autoLoad: {
				url: '<%= plural_name %>/' + ic.instanceId,
				method: 'GET',
				params: {context_id: ic.contextId}
			}
		});
		
		<%= controller_class_name %>.View.superclass.initComponent.call(this);
	}
});

Desktop.AppMgr.registerApp(<%= controller_class_name %>.View, {
	title: '<%= singular_name.capitalize %> View',
	appId: '<%= plural_name %>_view',
	iconCls: 'dt-icon-<%= plural_name %>',
	contextBar: true,
	controller: '<%= plural_name %>',
	dockContainer: Desktop.CENTER
});