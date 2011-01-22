Ext.ns("Desktop");

/**
 * @class Desktop.App
 * @extends Ext.Panel
 * <br />
 * @constructor
 * @param {Object} config The config object
 **/
Desktop.App = Ext.extend(Ext.Panel, {
 	closable: true,
	closeAction: 'close',
	dockonly: true,
	autoScroll: true,
    //stateful: false,
	plugins: [new Ext.ux.DockPanel({width: 300, height: 300})],
	getState: function(){
		return this.init
	},
	saveState: function(state){
		
	},
	/**
	 * Show an availiable button in the Mainbar menu
	 * @param {String} btnId The itemId of the button
	 * @param {App} instance The instance the button is attached to
	 */
	showButton : function(btnId){
		var btn = this.getTopToolbar().getComponent(btnId);
		if(btn){btn.show();}
	},
	
	/**
	 * Hide an availiable button in the Mainbar menu
	 * @param {String} btnId The itemId of the button
	 * @param {App} instance The instance the button is attached to
	 */	
	hideButton : function(btnId){
		var btn = this.getTopToolbar().getComponent(btnId);
		if(btn){btn.hide();}
	}
 });
 
 Ext.reg('dt_app', Desktop.App);