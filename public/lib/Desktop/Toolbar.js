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
			'-',
			{text: 'Community', itemId: 'community', iconCls: 'dt-icon-community',
			  handler: function(){
			    Desktop.AppMgr.display('community_index');
			  }
			},
			{text: 'Groups', itemId: 'groups', hidden:true, iconCls: 'dt-icon-groups',
			  handler: function(){
			    var current_user = Desktop.workspace.getCurrentUser();
			    Desktop.AppMgr.display('groups_index', current_user.id, {title: 'Groups'});
			  }
			},
			{text: 'Followers', itemId: 'followers', hidden:true, iconCls: 'dt-icon-followers',
			  handler: function(){
			    var current_user = Desktop.workspace.getCurrentUser();
			    Desktop.AppMgr.display('user_followers', current_user.id, {title: 'Followers'});
			  }
			},
			'-',
			{ text: 'Help', menu: helpMenu, iconCls: 'dt-icon-help'},
      '->',
			{ text: 'Login', itemId: 'login', iconCls: 'dt-icon-login',
			  handler: function(){
			    window.location = "accounts/login"
			  }
			},
			{ text: 'Account', id: 'accountBtn', itemId: 'account', hidden:true, 
			  handler: function(){
			    var current_user = Desktop.workspace.getCurrentUser();
					Desktop.AppMgr.display('user_form', current_user.id, {title: current_user.name});
			  }
			},
 			{ text: 'Logout', itemId: 'logout', hidden:true, iconCls: 'dt-icon-logout',
 			  handler: function(){
 			    window.location = "accounts/logout"
 			  }
 			}
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
		this.getComponent('groups').hide();
		this.getComponent('followers').hide();
		
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
		this.getComponent('groups').show();
		this.getComponent('followers').show();
		
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
		
	}
 });