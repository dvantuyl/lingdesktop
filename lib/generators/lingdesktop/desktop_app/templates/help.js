Ext.ns("<%= controller_class_name %>");

<%= controller_class_name %>.Help = Ext.extend(Desktop.App, {
	frame: true,
	initComponent : function() {		
		//apply all components to this app instance
		Ext.apply(this, {
			autoLoad: {
				url: 'help/<%= plural_name %>',
				method: 'GET'
			}
		});
 		
 		<%= controller_class_name %>.Help.superclass.initComponent.call(this);
 	}
});

Desktop.AppMgr.registerApp(<%= controller_class_name %>.Help, {
	title: '<%= controller_class_name %> Help',
	appId: '<%= plural_name %>_help',
	iconCls: 'dt-icon-<%= singular_name %>',
	dockContainer: Desktop.CENTER,
	displayMenu: 'help'
});