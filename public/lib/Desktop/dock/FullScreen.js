Ext.ns("Desktop","Desktop.dock");

Desktop.dock.FullScreen = Ext.extend(Ext.Panel, {
	layout: 'border',
	frame: false,
	initComponent: function() {
		var config = this.initialConfig;
		
		//create toolbar
		var toolbar = {
			xtype: 'dt_dock_toolbar', 
			region: 'north',
			hideExpand: true,
			listeners: {
				btnClick : function(btnLabel){
					if(btnLabel == '-'){
						Desktop.workspace.displayNormal();
					}
				}
			}
		}
		
		//buffer so that the dockpanel doesn't keep the border panel constraints as visible artifacts
		this.dockContainer = new Ext.Panel({
			region: 'center',
			layout: 'fit',
			border: false
		});
						
 		Ext.apply(this, {
 			items: [toolbar, this.dockContainer]
 		});
 		
 		Desktop.dock.FullScreen.superclass.initComponent.call(this);
 	},
	
	/**
	 * Set this full screen container's dock panel.
	 * @param {String} dockPanel_id The id of the dock panel to add
	 */
	setDockPanel: function(dockPanel_id){
		this.dockPanel_id = dockPanel_id;	//save for when we have to give the dock panel back to the original dock container
		var dockPanel = Ext.ComponentMgr.get(this.dockPanel_id);
		this.dockContainer.add(dockPanel);
	}
});
