Ext.ns("Desktop","Desktop.dock");

/**
 * @class Desktop.dock.Toolbar
 * @extends Ext.Panel
 * <br />
 * @constructor
 * @param {Object} config The config object
 **/
 Desktop.dock.Toolbar = Ext.extend(Ext.Panel, {
 	height: 15,
	cls: 'docktoolbar',
	xtype: 'panel',
	layout: 'hbox',
	hideCollapse: false,
	layoutConfig: {pack: 'end'},
	region: 'north',
	border: false,
 	initComponent : function() {
		var config = this.initialConfig;
		var constructBtn = function(label){
			return new Ext.BoxComponent({
				height: 13,
				hidden: (label == '-' && config.hideCollapse) || (label == '+' && config.hideExpand),
				autoEl:{tag:'div',html: label}, 
				onRender: function(){
					this.constructor.superclass.onRender.apply(this,arguments);
					this.el.on('click',function(e){
						this.fireEvent('btnClick', label);
					},this.ownerCt);
				}
			}); 
		};
		
		//init lingdesktop menu items		
 		this.menuItems = [
			constructBtn('+'), 
			constructBtn('-')
		];
 		
 		Ext.apply(this, {
 			items : this.menuItems
 		});
 		
 		Desktop.dock.Toolbar.superclass.initComponent.call(this);
 	}
 });
 
 
 
 Ext.reg('dt_dock_toolbar',Desktop.dock.Toolbar)
