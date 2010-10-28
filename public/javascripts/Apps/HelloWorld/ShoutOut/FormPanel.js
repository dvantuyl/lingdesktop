Ext.ns("HelloWorld.ShoutOut");

HelloWorld.ShoutOut.FormPanel = Ext.extend(Ext.form.FormPanel, {

	initComponent : function(){
		
		var shout_to = new Ext.form.TextField({
			name : 'shout_to',
			fieldLabel : 'Shout To',
			allowBlank : false
		});
		
		Ext.apply(this, {
			items: [
				shout_to
			]
		});
		
		HelloWorld.ShoutOut.FormPanel.superclass.initComponent.call(this);
	}
});
