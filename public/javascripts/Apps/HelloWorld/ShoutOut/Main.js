Ext.ns("HelloWorld.ShoutOut");

HelloWorld.ShoutOut.Main = Ext.extend(Desktop.App, {

	initComponent: function(){
		var form_panel = new HelloWorld.ShoutOut.FormPanel();
		
		var mainBar = [{
			text : 'Communicate',
			iconCls : 'dt-icon-cog',
			handler : function(){
				this.fireEvent('communicate');
			},
			scope : this
		}];
		
		Ext.apply(this, {
			mainBar : mainBar,
			items: [
				form_panel
			]
		});
		
		HelloWorld.ShoutOut.Main.superclass.initComponent.call(this);
		
		this.on('communicate', function(){
			var form_values = form_panel.getForm().getValues();
			var shout_to_val = form_values['shout_to'];
			var date = new Date();
			
			Desktop.AppMgr.display('helloworld_display', shout_to_val, {
				title : "Hello " + shout_to_val + "!",
				timeOfDay : date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds()
			});
		});
		
		
	}
});

Desktop.AppMgr.registerApp(HelloWorld.ShoutOut.Main, {
	appId: 'helloworld_shoutout',
	test: true,
	title: 'Shout Out',
	iconCls: 'dt-icon-user',
	displayMenu: 'public',
	dockContainer: Desktop.SOUTH
});
