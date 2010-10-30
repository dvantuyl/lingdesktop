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
		
	}
 });
 
 Ext.reg('dt_app', Desktop.App);