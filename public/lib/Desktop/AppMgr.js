Ext.ns('Desktop');

/**
 * @class Desktop.AppMgr
 * @singleton
 */
Desktop.AppMgr = function(){
    var apps = new Ext.util.MixedCollection();
	var focused;
	
    return {
        /**
         * Registers an app with title and icon used throughout the system.
         * @param {Desktop.App} app The App to register
         * @param {Object} config The app's configuration object
         */
        registerApp : function(app, config){
			//set defaults
			config.title=(config.title?config.title:'Untitled');
			config.iconCls=(config.iconCls?config.iconCls:'dt-icon-cog');
			config.displayMenu = (config.displayMenu?config.displayMenu:null); //optional (null to not display in any menus
			config.test=(config.test?true:false);
			config.appId = (config.appId?config.appId:null); //required
			config.dockContainer = (config.dockContainer?config.dockContainer:Desktop.CENTER);
			
			config.app = app;
			config.instances = {};
		
			//add app to the registry		
            apps.add(config.appId, config);
        },
		
		/**
     	 * Executes the specified function once for every item in the collection, passing the following arguments:
         * 
    	 *      * app : Desktop.App
                  The Desktop Application
    	 *      * title : String
				  The app's title
    	 *      * iconCls : String
      			  The location of the app's icon
         *      * test : Boolean
         *        Whether or not the app is in test mode
	     * The function should return a boolean value. Returning false from the function will stop the iteration.
	     * @param {Function} fn The function to execute for each item.
	     * @param {Object} scope (optional) The scope (this reference) in which the function is executed. Defaults to the current item in the iteration.
	     */
	    eachApp : function(fn, scope){
	        apps.keySort();
	        for(var i = 0, len = apps.getCount(); i < len; i++){
				var config = apps.itemAt(i);
	            if(fn.call(scope || config, config.appId, config) === false){
	                break;
	            }
	        }
	    },
		
		
		/**
		 * Displays an instance of an app or creates an instance adds to the app instances container
		 * @param {String} appId The application id to create
		 * @param {String} instanceId the id of this specific instance to display (Optional)
		 * @param {Object} params The configuration to init the application with (Optional)
		 */
		display : function(appId, instanceId, params){
			var config = apps.get(appId);
			var params = (params?params:{});
			var instance;
			
			//set instanceId to one given or 
			var instanceId=(instanceId?instanceId:null);
			
			//set sid
			if(!params.sid){
				var userid = Ext.util.Cookies.get('userid');
				params.sid = userid;
			}
			
			//setup instances space for sid
			if(!config.instances[params.sid]){
				config.instances[params.sid] = {}
			}
			
			//get singleton Instance based on instanceId
			if (config.instances[params.sid][instanceId]) {
				instance = config.instances[params.sid][instanceId];
				
			//or create a new instance if there isn't one
			}else {
				//set title
				if(params.title){
					//do nothing
				}else if(instanceId){
					params.title = instanceId;
				}else{
					params.title = config.title;
				}
				
				params.iconCls = config.iconCls;
				params.appId = config.appId;
				params.instanceId = instanceId;
						
				//dock the instance with the rest of the app instances if there are any or set to the one specified
				if(focused && config.appId == focused.appId){
					params.dockContainer = focused.dockContainer;
				}else{
					params.dockContainer = config.dockContainer;
				}
				Ext.ComponentMgr.get(params.dockContainer + '_container').fireEvent('expandDock');

				
				//create instance based on config and params
				instance = new config.app(params);
		
				//if the instance is destroyed then remove from the app instances container
				instance.on('destroy', function(i){
					if(focused == i){
						Desktop.AppMgr.unFocus();
					}
					delete config.instances[i.sid][i.instanceId];
				});
				
				//let workspace know that the user clicked on the instance thereby focusing it.
				instance.on('render',function(i){
					i.body.on('click', function(){
						Desktop.AppMgr.setFocused(i);
					})
				});
				
				//let workspace know that this the user has selected this app's tab thereby focusing it.
				instance.on('activate',function(i){
					Desktop.AppMgr.setFocused(i);
				});
				
				//add the instance to app instances container
				config.instances[params.sid][instanceId] = instance;
			}
		
			//check to make sure the dock panel that the app uses is expanded
			Ext.ComponentMgr.get(instance.dockContainer + '_container').fireEvent('expandDock');
			
			//set the instance as the active tab
			instance.getOwner().activate(instance);
		},
		
		unFocus : function(){
			if (focused) {
				Desktop.workspace.onAppUnfocus();
				focused.fireEvent('unfocused');
				focused = undefined;
			}
		},
		
		setFocused : function(instance){
			if(instance != focused){
				Desktop.AppMgr.unFocus();
				Desktop.workspace.onAppFocus(instance);
				instance.fireEvent('focused');
				focused = instance;
			}
		},
		
		getFocused : function(){
			return focused;
		},
		
		/**
		 * Creates all apps who's test config is true.
		 * Used for test mode
		 */
		initApps: function(mode){
			
			//clear apps
			Desktop.AppMgr.eachApp(function(appId, config){
				for(var i in config.instances){
					if (typeof config.instances[i] == 'object') {
						for(var s in config.instances[i]){
							if (typeof config.instances[i] == 'object') {
								config.instances[i][s].destroy();
							}
						}
						
					}
				}
			});
			
			//display apps
			if (mode == 'test'){ 
				Desktop.AppMgr.eachApp(function(appId, config){
					if (config.test) {
						Desktop.AppMgr.display(appId);
					}
				});
			}else{
				Desktop.AppMgr.display('ontology_gold');
				Desktop.AppMgr.display('desktop_welcome');
			}
		}

    };
}();
