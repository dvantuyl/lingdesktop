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


Desktop.workspace = function() {
    Ext.QuickTips.init();
    var viewport;
    var viewPanel;
    var borderPanel;
    var fullScreenPanel;
    var toolbar;
    var cookieUtil = Ext.util.Cookies;
    var current_user = {};

    return {
        init: function() {
            if (Ext.isIE) {
                //if the user's browser is IE then install Chrome frame
                CFInstall.check();
            } else {
                Ext.getBody().mask('Building UI', 'x-mask-loading');
                this.checkTestBit();
                //check to see if we're in test mode
                this.showViewport();
                this.checkAuthenticated();

                if (Desktop.test) {
                    Desktop.AppMgr.initApps('test');
                } else {
                    Desktop.AppMgr.initApps();
                }

            }
        },


        checkAuthenticated: function() {
            Ext.Ajax.request({
                url: 'users/current.json',
                success: function(response, opts) {
                   var decoded_response = Ext.decode(response.responseText);
                   if (decoded_response.success == true){
                     current_user = decoded_response.data;
                     toolbar.displayUser(current_user.email, current_user.is_admin);
                   }

                },
                failure: function() {
                    // console.log("ERROR: retrieve User failure.")
                }
            });
        },

        checkTestBit: function() {
            var query = window.location.search.substring(1);
            var vars = query.split('&');
            for (var i = 0, len = vars.length; i < len; i++) {
                var pair = vars[i].split("=");
                if (pair[0] == 'test' && pair[1] == 'true') {
                    Desktop.test = true;

                    break;
                }
            }
        },
        
        getCurrentUser: function(){
          return current_user;
        },

        onAppFocus: function(instance) {
            toolbar.setAppMenu(instance);
        },

        onAppUnfocus: function() {
            toolbar.clearAppMenu();
        },

        getMainBar: function() {
            return toolbar;
        },

        getCookieUtil: function() {
            return cookieUtil;
        },


        showViewport: function() {

            if (!viewport) {

                toolbar = new Desktop.Toolbar();

                borderPanel = new Ext.Panel({
                    layout: 'border',
                    border: false,
                    items: [
                    {
                        xtype: 'dt_dock_panel',
                        region: 'west',
                        split: true,
                        dockId: Desktop.WEST,
                        collapseDock: true
                    },
                    {
                        xtype: 'dt_dock_panel',
                        region: 'east',
                        split: true,
                        dockId: Desktop.EAST
                    },
                    {
                        xtype: 'panel',
                        layout: 'border',
                        region: 'center',
                        items: [
                        {
                            xtype: 'dt_dock_panel',
                            region: 'center',
                            hideCollapse: true,
                            dockId: Desktop.CENTER
                        },
                        {
                            xtype: 'dt_dock_panel',
                            region: 'south',
                            split: true,
                            dockId: Desktop.SOUTH,
                            collapseDock: true
                        }
                        ]
                    }
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
                    layout: 'fit',
                    border: false,
                    items: viewPanel
                });
                Ext.getBody().unmask();
            }
        },

        displayFullScreen: function(dockPanel_id) {
            fullScreenPanel.setDockPanel(dockPanel_id);
            viewPanel.layout.setActiveItem(1);
            viewPanel.doLayout();
        },

        displayNormal: function() {
            Ext.ComponentMgr.get(fullScreenPanel.dockPanel_id + '_container').setDockPanel(fullScreenPanel.dockPanel_id);
            viewPanel.layout.setActiveItem(0);
            viewPanel.doLayout();
        },

        onAfterAjaxReq: function(options, success, result) {
            if (success) {
                var jsonData;
                try {
                    jsonData = Ext.decode(result.responseText);
                }
                catch(e) {
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
} ();

var dropZoneOverrides = {
    ddGroup: 'resource',
    onContainerOver: function(ddSrc, evtObj, ddData) {
        var destGrid = this.grid;
        var tgtEl = evtObj.getTarget();
        var tgtIndex = destGrid.getView().findRowIndex(tgtEl);
        this.clearDDStyles();
        if (typeof tgtIndex === 'number') {
            var tgtRow = destGrid.getView().getRow(tgtIndex);
            var tgtRowEl = Ext.get(tgtRow);
            var tgtRowHeight = tgtRowEl.getHeight();
            var tgtRowTop = tgtRowEl.getY();
            var tgtRowCtr = tgtRowTop + Math.floor(tgtRowHeight / 2);
            var mouseY = evtObj.getXY()[1];
            if (mouseY >= tgtRowCtr) {
                this.point = 'below';
                tgtIndex++;
                tgtRowEl.addClass('gridRowInsertBottomLine');
                tgtRowEl.removeClass('gridRowInsertTopLine');
            }
            else
            if (mouseY < tgtRowCtr) {
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
        destGrid.body.addClass('gridBodyNotifyOver');
        return this.dropAllowed;
    },
    notifyOut: function() {
        // 1
        this.clearDDStyles();
    },
    clearDDStyles: function() {
        this.grid.body.removeClass('gridBodyNotifyOver');
        if (this.overRow) {
            this.overRow.removeClass('gridRowInsertBottomLine');
            this.overRow.removeClass('gridRowInsertTopLine');
        }
    },
    onContainerDrop: function(ddSrc, evtObj, ddData) {
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
        if (ddData.selections) {
            data = ddData.selections[0].data;
        } else if (ddData.node) {
            data = ddData.node.attributes
        }
        grid.fireEvent('datadrop', destStore, data);
        return true;
    }
};


Ext.apply(Ext.layout.FormLayout.prototype, {
    originalRenderItem: Ext.layout.FormLayout.prototype.renderItem,
    renderItem: function(c, position, target) {
        if (c && !c.rendered && c.fieldLabel && c.requiredField === true && c.hidden === false) {
            c.fieldLabel = c.fieldLabel + "<span style='color: red'>*</span>";
        }
        this.originalRenderItem.apply(this, arguments);
    }
});

Ext.onReady(Desktop.workspace.init, Desktop.workspace);