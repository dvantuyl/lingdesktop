Ext.ns("Desktop");
/**
 * @class Desktop.workspace
 *
 * <br />
 * @constructor
 * @singleton
 **/

//Set Desktop globals
Desktop.WEST = 'westdock';
Desktop.CENTER = 'centerdock';
Desktop.EAST = 'eastdock';
Desktop.SOUTH = 'southdock';
Desktop.test = false;
Desktop.authenticated = false;

Desktop.workspace = function(){
	Ext.QuickTips.init();
	var viewport, viewPanel, borderPanel, fullScreenPanel, loginWindow, toolbar,
		cookieUtil = Ext.util.Cookies;
	
	return {
		init : function() {
			if(Ext.isIE){	//if the user's browser is IE then install Chrome frame
				CFInstall.check();
			}else{
				Ext.getBody().mask('Building UI', 'x-mask-loading');
				this.checkTestBit();	//check to see if we're in test mode
				this.showViewport();
				this.checkAuthenticated();
				
				if(Desktop.test){
					Desktop.AppMgr.initApps('test');
				}else{
					Desktop.AppMgr.initApps();
				}
				
			}
		},
		
		checkAuthenticated : function(){
			var loginCookie = cookieUtil.get('loginCookie');
			var userid = cookieUtil.get('userid');
			var is_admin = cookieUtil.get('is_admin')
			if(loginCookie && userid){
				toolbar.displayUser(userid, is_admin);
				return loginCookie;
			}else{
				cookieUtil.set('userid', 'guest');
				cookieUtil.set('is_admin', 'false');
				return false;
			}
		},
		
		checkTestBit : function(){
			var query = window.location.search.substring(1);
			var vars = query.split('&');
			for(var i=0,len=vars.length;i<len;i++){
				var pair = vars[i].split("=");
				if(pair[0]=='test' && pair[1]=='true'){
					Desktop.test = true;
					
					break;
				}
			}
		},
		
		onAppFocus : function(instance){
			toolbar.setAppMenu(instance);
		},
		
		onAppUnfocus : function(){
			toolbar.clearAppMenu();
		},
		
		getMainBar : function(){
			return toolbar;
		},
		
		getCookieUtil : function(){
			return cookieUtil;
		},

        showLoginWindow : function() {
            if (! loginWindow) {
                loginWindow = this.constructLoginWindow();
            }

            loginWindow.show();
        },
        
        constructLoginWindow : function() {
            var formItemDefaults = {
                allowBlank : false,
                anchor     : '-5',
                listeners  : {
                    scope      : this,
                    specialkey : function(field, e) {
                        if (e.getKey() === e.ENTER) {
                            this.doLogin();
                        }
                    }
                }
            };

            var formLoginItems = [{
                    fieldLabel : 'User Name',
                    name       : 'login'
                },{
                    inputType  : 'password',
                    fieldLabel : 'Password',
                    name       : 'password',
					msgTarget  : 'under'
            }];

            return  new Ext.Window({
                width     : 250,
                height    : 140,
                modal     : true,
                draggable : false,
                title     : 'Login to LingDesktop',
                layout    : 'fit',
                center    : true,
                closable  : false,
                resizable : false,
                border    : false,
                items     : {
                    xtype       : 'form',
                    defaultType : 'textfield',
                    labelWidth  : 70,
                    frame       : true,
                    url         : 'login_handler',
                    labelAlign  : 'right',
                    defaults    : formItemDefaults,
                    items       : formLoginItems
                },
                buttons : [
                    {
                        text    : 'Login',
                        handler : this.doLogin,
                        scope   : this
                    },'->',{
						text	: 'Cancel',
						handler : function(){
							loginWindow.destroy();
                			loginWindow = null;
						}
					}
                ]
            });
        },

        doLogin :  function() {
            var form = loginWindow.get(0);
            if (form.getForm().isValid()) {
                loginWindow.el.mask('Please wait...', 'x-mask-loading');
				
				form.getForm().submit({
					success : function(f,a){ 
						var userid = a.result.userid;
						var is_admin = a.result.is_admin;
						cookieUtil.set('userid',userid);
						cookieUtil.set('is_admin',is_admin);
						this.onLoginSuccess();
					},
					failure : function(f,a){ 
						this.onLoginFailure();
					},
					scope : this
				});
            }
        },

        onLoginSuccess : function() {
			loginWindow.el.unmask();
            var loginCookie = cookieUtil.get('loginCookie');
			var userid = cookieUtil.get('userid');
			var is_admin = cookieUtil.get('is_admin');
            if (loginCookie && userid) {
				toolbar.displayUser(userid, is_admin);
				loginWindow.destroy();
                loginWindow = null;
            }
            else {
                this.onLoginFailure();
            }
        },

        onLoginFailure : function() {
           loginWindow.el.unmask();
        },

        showViewport : function() {
		
            if (! viewport) {
				
            	toolbar = new Desktop.Toolbar();
				toolbar.on('login',this.showLoginWindow, this);
				toolbar.on('logout',this.onLogOut, this);
				toolbar.on('account',function(){
					var userid = cookieUtil.get('userid');
					Desktop.AppMgr.display('user_form', userid);
				});
            
                borderPanel = new Ext.Panel({
                    layout  : 'border',
					border	: false,
                    items      :  [
                    	{xtype: 'dt_dock_panel', region: 'west', split:true, dockId: Desktop.WEST, collapseDock: true},
                    	{xtype: 'dt_dock_panel', region: 'east', split:true, dockId: Desktop.EAST},
						{xtype: 'panel', layout:'border', region: 'center', items:[
							{xtype: 'dt_dock_panel', region: 'center', hideCollapse: true, dockId: Desktop.CENTER},
                    		{xtype: 'dt_dock_panel', region: 'south', split: true, dockId: Desktop.SOUTH, collapseDock: true}
						]}
                    ]
                });
				
				fullScreenPanel = new Desktop.dock.FullScreen();
				
				viewPanel = new Ext.Panel({
					layout: 'card',
					tbar: toolbar,
					activeItem: 0,
					items: [borderPanel, fullScreenPanel]
				});

                viewport = new Ext.Viewport({
                    layout : 'fit',
					border : false,
                    items  : viewPanel
                });
                Ext.getBody().unmask();
            }
        },
		
		displayFullScreen : function(dockPanel_id){
			fullScreenPanel.setDockPanel(dockPanel_id);
			viewPanel.layout.setActiveItem(1);
			viewPanel.doLayout();
		},
		
		displayNormal : function(){
			Ext.ComponentMgr.get(fullScreenPanel.dockPanel_id + '_container').setDockPanel(fullScreenPanel.dockPanel_id);
			viewPanel.layout.setActiveItem(0);
			viewPanel.doLayout();
		},

        onLogOut : function() {
            toolbar.displayGuest();
            	Ext.Ajax.request({
						url: 'logout_handler',
						method: 'POST'
					});
				cookieUtil.set('is_admin', null, new Date("January 1, 1970"), '/');
				cookieUtil.set('userid', null, new Date("January 1, 1970"), '/');
			
			if(Desktop.test){
				Desktop.AppMgr.initApps('test');
			}else{
				Desktop.AppMgr.initApps();
			}
        },

        onAfterAjaxReq : function(options, success, result) {
            if (success) {
                var jsonData;
                try {
                    jsonData = Ext.decode(result.responseText);
                }
                catch (e) {
                    Ext.MessageBox.alert('Error!', 'Data returned is not valid data!');
                }
                options.succCallback.call(options.scope, jsonData, options);

            }
            else {
                Ext.MessageBox.alert('Error!', 'The web transaction failed!');
            }
            Ext.getBody().unmask();
        }
        
    };
}();

var dropZoneOverrides = {
    ddGroup: 'resource',
    onContainerOver: function(ddSrc, evtObj, ddData){
        var destGrid = this.grid;
        var tgtEl = evtObj.getTarget();
        var tgtIndex = destGrid.getView().findRowIndex(tgtEl); // 1
        this.clearDDStyles();
        if (typeof tgtIndex === 'number') { // 2
            var tgtRow = destGrid.getView().getRow(tgtIndex);
            var tgtRowEl = Ext.get(tgtRow);
            var tgtRowHeight = tgtRowEl.getHeight();
            var tgtRowTop = tgtRowEl.getY();
            var tgtRowCtr = tgtRowTop + Math.floor(tgtRowHeight / 2);
            var mouseY = evtObj.getXY()[1];
            if (mouseY >= tgtRowCtr) { // 3
                this.point = 'below';
                tgtIndex++;
                tgtRowEl.addClass('gridRowInsertBottomLine');
                tgtRowEl.removeClass('gridRowInsertTopLine');
            }
            else 
                if (mouseY < tgtRowCtr) { // 4
                    this.point = 'above';
                    tgtRowEl.addClass('gridRowInsertTopLine');
                    tgtRowEl.removeClass('gridRowInsertBottomLine')
                }
            this.overRow = tgtRowEl;
        }
        else {
            tgtIndex = destGrid.store.getCount();
        }
        this.tgtIndex = tgtIndex;
        destGrid.body.addClass('gridBodyNotifyOver'); // 6
        return this.dropAllowed;
    },
    notifyOut: function(){ // 1
        this.clearDDStyles();
    },
    clearDDStyles: function(){ // 2
        this.grid.body.removeClass('gridBodyNotifyOver');
        if (this.overRow) {
            this.overRow.removeClass('gridRowInsertBottomLine');
            this.overRow.removeClass('gridRowInsertTopLine');
        }
    },
    onContainerDrop: function(ddSrc, evtObj, ddData){ // 3
        /*
		var grid = this.grid;
        var srcGrid = ddSrc.view.grid;
        var destStore = grid.store;
        var tgtIndex = this.tgtIndex;
        var records = ddSrc.dragData.selections;
        this.clearDDStyles();
        var srcGridStore = srcGrid.store;
        Ext.each(records, srcGridStore.remove, srcGridStore); // 4
        if (tgtIndex > destStore.getCount()) {
            tgtIndex = destStore.getCount();
        }
        destStore.insert(tgtIndex, records); // 5
        */
		var grid = this.grid;
		var destStore = grid.store;
		var data = null;
		if(ddData.selections){
			data = ddData.selections[0].data;
		}else if(ddData.node){
			data = ddData.node.attributes
		}
		grid.fireEvent('datadrop', destStore, data);
        return true;
    }
};


Ext.apply(Ext.layout.FormLayout.prototype, {
    originalRenderItem:Ext.layout.FormLayout.prototype.renderItem,
    renderItem:function(c, position, target){
        if(c && !c.rendered && c.fieldLabel && c.requiredField === true && c.hidden === false) {
            c.fieldLabel = c.fieldLabel + "<span style='color: red'>*</span>";
        }
        this.originalRenderItem.apply(this, arguments);
    }
});




Ext.onReady(Desktop.workspace.init, Desktop.workspace);