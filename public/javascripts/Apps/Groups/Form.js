Ext.ns("Groups");

Groups.Form = Ext.extend(Desktop.App, {
  frame: true,
	autoScroll: true,
	
	initComponent : function() {		
	  
	  var ic = this.initialConfig; //configuration given to Desktop.App
	  
	  //setup fields
	    var name = new Ext.form.TextField({
	      fieldLabel: 'Name', 
	      name: 'name',
	      allowBlank: false,
        requiredField: true,
	      width: 165
	    });
	    
	    var description = new Ext.form.TextArea({
          height: 100,
          width: 685,
          fieldLabel: 'Description',
          name: 'description'
      });
      
      //setup hasMeaningGrid GOLD Grid
      var membersGrid = new Groups.DropGrid({
          ddGroup : 'community',
          height: 150,
          fieldLabel: 'Please select and drag a Member from the Community to the space below',
          stripeRows: true,
          
          store: new Ext.data.JsonStore({
              // store configs
              autoDestroy: true,
              url: 'groups/' + ic.instanceId + '/members.json',
              // reader configs
              root: 'data',
              idProperty: 'id',
              fields: ['id','name', 'description', 'is_group']
          }),
          autoExpandColumn: 'description',
          columns: [
            { 
              width: 10,
              dataIndex: 'is_group',
              renderer: function(val){
                if(val){
                  return '<img src="' + '/images/icons/group.png' + '">';
                }else{
                  return '<img src="' + '/images/icons/user.png' + '">';
                }
              }
            },
            {
                header: 'Name',
                dataIndex: 'name'
            },
            {
                id: 'description',
                header: 'Description',
                dataIndex: 'description'
            }
          ]

      });

      //setup form
      this.form = new Ext.FormPanel({
          labelAlign: 'top',
          frame: true,
          width: 700,
          url: 'groups',
          baseParams: {
              format: 'json'
          },
          items: [{
              layout: 'column',
              border: false,
              items: [{
                  layout: 'form',
                  labelWidth: 90,
                  columnWidth: .5,
                  border: false,
                  items: name
              }]
          },
          description, membersGrid]
      });
      
      //setup toolbar
      var toolbar = [
        {
            text: 'Save',
            iconCls: 'dt-icon-save',
            handler: function() {
                this.fireEvent('save')
            },
            scope: this
        }
      ];
      
      //condition based on whether this form is an instance of an already instatiated record
      if (ic.instanceId) {

          //add delete button
          toolbar.push({
              text: 'Delete',
              iconCls: 'dt-icon-delete',
              handler: function() {
                  this.fireEvent('delete')
              },
              scope: this
          });

          //Load server -> form values if we have the ic.instance_id
          var id = ic.instanceId;
          this.form.form.url = 'groups/' + id + '.json';
          this.form.load({
              method: 'GET'
          });

          membersGrid.getStore().load({
              method: 'GET'
          });
          
          membersGrid.groupId = id;
      } else {
          this.form.form.url = 'groups.json';
      }
      
      //apply all components to this app instance
      Ext.apply(this, {
          items: this.form,
          tbar: toolbar
      });

      //call App initComponent
      Groups.Form.superclass.initComponent.call(this);
	    
      //event handlers
      this.on('save',
      function() {
          var memberIds = membersGrid.store.collect('id');
          var save_config = {
              scope: this,
              params: {
                  "members": Ext.encode(memberIds)
              }
          };
          
          if (ic.instanceId) {
              save_config.params['_method'] = 'PUT';
          }

          save_config.success = function() {
              this.destroy();
              
              Desktop.AppMgr.display('groups_index');
              
              var groups_store = Ext.StoreMgr.get('groups_index');
              if (groups_store) {groups_store.reload();}
              
              var community_store = Ext.StoreMgr.get('community_index');
              if (community_store) {community_store.reload();}
          }

          this.form.getForm().submit(save_config);
      },
      this);

      this.on('delete',
      function() {
          Ext.Msg.confirm('Delete', 'Are you sure you want to delete?',

          function(btn) {
              if (btn == 'yes') {

                  Ext.Ajax.request({
                      url: 'groups/' + ic.instanceId + '.json',
                      method: 'POST',
                      success: function() {
                        var groups_store = Ext.StoreMgr.get('groups_index');
                        if (groups_store) {groups_store.reload();}
                        
                        var community_store = Ext.StoreMgr.get('community_index');
                        if (community_store) {community_store.reload();}
                        
                        this.destroy();
                      },
                      params: {
                          '_method': 'DELETE'
                      },
                      scope: this
                  });
              }
          },
          this);
      },
      this);
      
      Desktop.AppMgr.display('community_index');
  }
});

Desktop.AppMgr.registerApp(Groups.Form, {
  title: 'Edit Group',
  iconCls: 'dt-icon-groups',
  appId: 'groups_form',
  dockContainer: Desktop.CENTER
});
