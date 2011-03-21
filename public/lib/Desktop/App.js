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
	pageSize: 20,
	plugins: [new Ext.ux.DockPanel({width: 300, height: 300})],
	
	initComponent: function(){
	  var ic = this.initialConfig;

	  if(ic.contextBar){
	    var contextBar = [];
	    var current_user = Desktop.workspace.getCurrentUser();
	    
	    // edit/clone button
	    if (current_user.context_id){
	      contextBar.push({
	          xtype: 'button',
	          text: 'Edit',
	          iconCls: 'dt-icon-edit',
	          handler: function(){
	            Ext.Ajax.request({
	              url: ic.controller + '/' + ic.instanceId + '/clone.json',
	              params: { from_id : ic.contextId, context_id : current_user.context_id },
	              success: function(){
	                Desktop.AppMgr.display(ic.controller + '_edit', ic.instanceId, {title: ic.title});
	              }
	            });
	          }
	        },
	        {
	          xtype: 'tbseparator'
	        }
	      );
	    }
	    
	    //current context
	    Ext.Ajax.request({
          url: 'contexts/' + ic.contextId + '.json',
          success: function(response, opts) {
            var obj = Ext.decode(response.responseText);
            var contextBar = this.getBottomToolbar();
            contextBar.add(
              'Current View:',
              {
                xtype: 'button',
                iconCls: (obj.data.is_group ? 'dt-icon-groups' : 'dt-icon-user'),
                text: obj.data.name,
                handler : function(){
                  Desktop.AppMgr.display('community_view', ic.contextId, {title: obj.data.name});
                }
              }
            );
            contextBar.doLayout();
          },
          scope: this
      });
      
      //created by context
      Ext.Ajax.request({
          url: ic.controller + '/' + ic.instanceId + '.json',
          method: 'GET',
          success: function(response, opts) {
            var obj = Ext.decode(response.responseText);
            var contextBar = this.getBottomToolbar();
            contextBar.add(
              {xtype: 'tbseparator'},
              'Creator:',
              {
                xtype: 'button',
                iconCls: 'dt-icon-user',
                text: obj.data.creator_name,
                handler : function(){
                  Desktop.AppMgr.display('community_view', obj.data.creator_id, {title: obj.data.creator_name});
                }
              }
            );
            contextBar.doLayout();
          },
          scope: this
      });
	    
	    
	    Ext.apply(this, {
          bbar: contextBar
      });
	  }
	  
	  Desktop.App.superclass.initComponent.call(this);
	},
	
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