Ext.ns("Desktop");

/**
 * @class Desktop.Toolbar
 * @extends Ext.Toolbar
 * <br />
 * @constructor
 * @param {Object} config The config object
 **/
 Desktop.Toolbar = Ext.extend(Ext.Toolbar, {
 	initComponent : function() {
		
		//create the app menu to let user select an app
		var appMenu = new Ext.menu.Menu();
		var adminMenu = new Ext.menu.Menu();
		var helpMenu = new Ext.menu.Menu();
		this.userMenu = [];
		
		var _this = this;
		Desktop.AppMgr.eachApp(function(key, app){
			//Don't allow apps in test mode into the menu unless we're in test mode		
			if (!app.test || Desktop.test) {
				
				//add admin menu items
				if (app.displayMenu == 'admin') {
					adminMenu.add({
						text: app.title,
						iconCls: app.iconCls,
						handler: function(){
							Desktop.AppMgr.display(key);
						}
					});
				
				//add help menu items
				}else if (app.displayMenu == 'help') {
					helpMenu.add({
						text: app.title,
						iconCls: app.iconCls,
						handler: function(){
							Desktop.AppMgr.display(key);
						}
					});
					
				//add public menu items
				}else if (app.displayMenu == 'public') {
					appMenu.add({
						text: app.title,
						iconCls: app.iconCls,
						handler: function(){
							Desktop.AppMgr.display(key);
						}
					});
					
				//add user menu items
				}else if (app.displayMenu == 'user') {
					var btn = new Ext.menu.Item({
						text: app.title,
						hidden: true,
						iconCls: app.iconCls,
						handler: function(){
							Desktop.AppMgr.display(key);
						}
					});
					appMenu.add(btn);
					_this.userMenu.push(btn);	//reference user menu items for hidding and showing based on login
				}
			}
		});
		//add the admin menu to the public menu
		appMenu.add({text:'Admin', itemId:'admin', menu: adminMenu, hidden: true});

		//init lingdesktop menu items		
 		var mainBar = [
        	{ itemId: 'start', text: 'Main Menu', iconCls: 'dt-icon-cog', menu: appMenu },
			'-',{xtype: 'tbtext', text: '', itemId: 'current'},
        	'->',
			{ text: 'Login', itemId: 'login', 
			  handler: function(){
			    window.location = "authentication/login"
			  }
			},
			{ text: 'Account', id: 'accountBtn', itemId: 'account', hidden:true, 
			  handler: function(){
			    var current_user = Desktop.workspace.getCurrentUser();
					Desktop.AppMgr.display('user_form', current_user.localname);
			  }
			},
 			{ text: 'Logout', itemId: 'logout', hidden:true, 
 			  handler: function(){
 			    window.location = "authentication/logout"
 			  }
 			},
			{ text: 'Help', menu: helpMenu}
 		];
 		
 		Ext.apply(this, {
 			items : mainBar
 		});
 		
 		Desktop.Toolbar.superclass.initComponent.call(this);
 	},
	
	displayGuest : function(){
		this.getComponent('login').show();
		this.getComponent('account').hide();
		this.getComponent('logout').hide();
		
		this.getComponent('start').menu.getComponent('admin').hide();
		
		//hide menu items that are only accessable to logged in users
		for(var i=0,l=this.userMenu.length; i < l; i++){
			this.userMenu[i].hide();
		}
	},
		
	displayUser : function(userid, is_admin){
		this.getComponent('login').hide();
		var account_item = this.getComponent('account')
		Ext.query('.x-btn-text',account_item.el.dom)[0].innerHTML = userid; //set account button to userid
		account_item.show();
		this.getComponent('logout').show();
		
		//show admin menu if admin
		if(is_admin == true){
			this.getComponent('start').menu.getComponent('admin').show();
		}else{
			this.getComponent('start').menu.getComponent('admin').hide();
		}
		
		//show menu items that are only accessable to logged in users
		for(var i=0,l=this.userMenu.length; i < l; i++){
			this.userMenu[i].show();
		}
		
	},
	
	setAppMenu : function(instance){
		//set display app
		var currentEl = this.getComponent('current').el.dom;
		currentEl.innerHTML = instance.title;
		
		
		//interate through all the app buttons
		if (instance.mainBar) {		
			this.appItems = []; //container to keep track of toolbar items added from the app;
			var start = 3; //the starting point to insert buttons into the mainbar
			for (var i = 0, l = instance.mainBar.length; i < l; i++) {
				
				appItem = instance.mainBar[i];
				
				//add item id if there isn't one
				appItem.itemId = (appItem.itemId?appItem.itemId:'dt-mainBarItem-'+i);
				this.appItems[i] = appItem.itemId;
				
				//insert appItem into the mainbar
				this.insert((start + i), appItem);
			}
			this.doLayout();
		}
	},
	
	clearAppMenu : function(){	
		//set display app
		var currentEl = this.getComponent('current').el.dom;
		currentEl.innerHTML = '';
		
		//clear items from previous app if any
		if (this.appItems) {
			for (var i = 0, l = this.appItems.length; i < l; i++) {
				this.remove(this.appItems[i]);
			}
		}
	},
	
	/**
	 * Show an availiable button in the Mainbar menu
	 * @param {String} btnId The itemId of the button
	 * @param {App} instance The instance the button is attached to
	 */
	showButton : function(btnId, instance){
		if (Desktop.AppMgr.getFocused() != instance) {
			instance.on('focused', function(){
				var btn = this.getComponent(btnId);
				if(btn){btn.show();}
			}, this);
		}else{
				var btn = this.getComponent(btnId);
				if(btn){btn.show();}
		}
	},
	
	/**
	 * Hide an availiable button in the Mainbar menu
	 * @param {String} btnId The itemId of the button
	 * @param {App} instance The instance the button is attached to
	 */	
	hideButton : function(btnId, instance){
		if (Desktop.AppMgr.getFocused() != instance) {
			instance.on('focused', function(){
				var btn = this.getComponent(btnId);
				if(btn){btn.hide();}
			}, this);
		}else{
				var btn = this.getComponent(btnId);
				if(btn){btn.hide();}
		}
	}
 });