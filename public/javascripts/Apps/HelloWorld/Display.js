Ext.ns("HelloWorld");

HelloWorld.Display = Ext.extend(Desktop.App, {
	initComponent : function(){
		
		var ic = this.initialConfig;
		
		var my_msg = "Hello " + ic.instanceId + "!" + 
					"<br/><br/>" +
					"The time is " + ic.timeOfDay;

		
		Ext.apply(this, {
			html : my_msg
		});

		
		HelloWorld.Display.superclass.initComponent.call(this);
	}
});

Desktop.AppMgr.registerApp(HelloWorld.Display, {
	appId: 'helloworld_display',
	title: 'Hello World!',
	iconCls: 'dt-icon-user',
	displayMenu: 'public',
	dockContainer: Desktop.West
});
