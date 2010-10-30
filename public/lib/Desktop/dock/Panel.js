Ext.ns("Desktop","Desktop.dock");

Desktop.dock.Panel = Ext.extend(Ext.Panel, {
	layout: 'card',
	frame: false,
	initComponent: function() {
		var config = this.initialConfig;
		
		//create expandBar
		var expandBar = new Ext.BoxComponent({
				hidden: true,
				cls: 'expand-bar',
				autoEl:{tag:'div',html: '+'}, 
				onRender: function(){
					this.constructor.superclass.onRender.apply(this,arguments);
					this.el.on('click',function(e){
						this.fireEvent('expandDock');
					},this.ownerCt);
				}
		});
		
		//create tab panel
		var tabPanel = new Ext.ux.DockTabPanel({
			id: config.dockId, 
			enableTabScroll: true, 
			border:false, 
			region: 'center'
		});
		
		//create toolbar
		var toolbar = {
			xtype: 'dt_dock_toolbar', 
			region: 'north',
			hideCollapse: config.hideCollapse,
			listeners: {
				btnClick : function(btnLabel){
					if(btnLabel == '-'){
						this.ownerCt.ownerCt.fireEvent('collapseDock');
					}else if(btnLabel == '+'){
						Desktop.workspace.displayFullScreen(config.dockId)
					}
				}
			}
		}
		
		//buffer so that the dockpanel doesn't keep the border panel constraints as visible artifacts
		this.dockContainer = new Ext.Panel({
			region: 'center',
			layout: 'fit',
			border: false,
			items: tabPanel
		});
		
		//holds the default view of the panel
		var container = new Ext.Panel({
			layout: 'border',
			border: false,
			region: 'center',
			items: [toolbar, this.dockContainer]
		});
		
		//set extra configuration
		var applyConfig = {
			id: config.dockId + '_container',
 			items : [container,expandBar]
		};
		
		//init collapse or normal state based on collapseDock configuration
		if(config.collapseDock && config.region != 'center'){
			this.is_collapseDock = true;
			applyConfig.activeItem = 1;
			if (config.region == 'south') {
				applyConfig.height = 20;
			}else{
				applyConfig.width = 20;
			}
		}else{
			this.is_collapseDock = false;
			applyConfig.activeItem = 0;
			if (config.region == 'south') {
				applyConfig.height = 220;
			}else{
				applyConfig.width = 220;
			}
		}
		
 		Ext.apply(this, applyConfig);
 		
 		Desktop.dock.Panel.superclass.initComponent.call(this);
		
		this.on('collapseDock',function(){
			this.is_collapseDock = true;
			this.layout.setActiveItem(1);
			if (config.region == 'south') {
				this.setHeight(20);
			}else{
				this.setWidth(20);
			}
			this.ownerCt.ownerCt.doLayout();
		});
		
		this.on('expandDock',function(){
			if (this.is_collapseDock) {
				this.is_collapseDock = false;
				this.layout.setActiveItem(0);
				if (config.region == 'south') {
					this.setHeight(220);
				}
				else {
					this.setWidth(220);
				}
				this.ownerCt.ownerCt.doLayout();
			}
		});
		
		Ext.ComponentMgr.register(this);
 	},
	
	/**
	 * Set this container's dock panel. Used for restoring the dock to normal view from full screen.
	 * @param {String} dockPanel_id The id of the dock panel to add
	 */
	setDockPanel: function(dockPanel_id){
		var dockPanel = Ext.ComponentMgr.get(dockPanel_id);
		this.dockContainer.add(dockPanel);
	},
});

Ext.reg('dt_dock_panel', Desktop.dock.Panel);
