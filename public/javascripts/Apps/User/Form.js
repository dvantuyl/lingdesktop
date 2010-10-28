Ext.ns("User");

User.Form = Ext.extend(Desktop.App, {
	frame: true,
	autoScroll: true,
	
	initComponent : function() {		
	  
	  var ic = this.initialConfig; //configuration given to Desktop.App
	 
	 	//setup fields
	    var firstname = new Ext.form.TextField({
	      fieldLabel: 'First Name', 
	      name: 'first_name',
	      width: 165,
	    });
	    
	    var lastname = new Ext.form.TextField({
	        fieldLabel: 'Last Name', 
	        name: 'last_name',
	        width: 165,
	      });
	    
	    var email = new Ext.form.TextField({
	        fieldLabel: 'Email', 
	        name: 'email',
	        width: 165,
	        regex: /^([\w\-\'\-]+)(\.[\w-\'\-]+)*@([\w\-]+\.){1,5}([A-Za-z]){2,4}$/
	      });
	    
		var username = new Ext.form.TextField({
		  allowBlank: false,
		  requiredField: true,
	      fieldLabel: 'Username', 
	      name: 'username',
	      width: 165,
	    });
		
	    var password = new Ext.form.TextField({
	        fieldLabel: 'Password',
	        name: 'password', 
	        itemId:'password',
	        inputType:'password',
	        width: 165,
			validator: function(value){
				return ((password.hidden || value.length >= 5)?true:"Password must be at least 5 characters long")
			}
	      });
	    
	    var retypepassword = new Ext.form.TextField({
	        fieldLabel: 'Retype Password',
	        name: 'retypepassword', 
	        inputType:'password',
	        width: 165,
			validator : function(value){
				return ((password.getValue() == value)?true:"Password does not match");
			}
	      });
		  
		var setpassword = new Ext.Button({
			hidden: true,
			text: 'Set Password',
			handler: function(){
				password.enable();
				password.show();
				retypepassword.show();
				setpassword.hide();
			}
		});
	    
		var hidden_admin = new Ext.form.Hidden({
			name: 'is_admin'
		});
	  
	    var is_admin = new Ext.form.Checkbox({
	    	fieldLabel:'Administrator',
			name: 'is_admin',
	    	submitValue: false,
			handler : function(chkbox, checked){
				hidden_admin.setValue(checked);
			}
	    });
		
		var hidden_active = new Ext.form.Hidden({
			name: 'is_active'
		});
	  
	    //active by default. can only change after created
	    var is_active = new Ext.form.Checkbox({
	    	fieldLabel:'Active',
			name: 'is_active',
	    	submitValue: false,
			checked: true,
			disabled: true,
			handler : function(chkbox, checked){
				hidden_active.setValue(checked);
			}
	    });		
	 	
		//setup form
	    this.form = new Ext.FormPanel({
	    	frame: true,
			width: 700,
	    	url:'users',
	    	baseParams: {format:'json'},
	    	items: [{
		  	  layout: 'column',
		      border: false,
		      items: [{
		        layout: 'form',
		        labelWidth: 90,
		        columnWidth: .5,
		        border: false,
		        items: [
				  username,
		          firstname,
				  lastname, 
				  email 
				]
			  },{
			  	layout:'form',
			  	labelWidth: 120,
				columnWidth: .5,
				border: false,
				trackLabels: true,
				items: [
				   setpassword,
				   password,
				   retypepassword,
				   is_admin,
				   hidden_admin,
				   is_active,
				   hidden_active
				]
			  }]
	    	}]
	    });
		
		
		//setup mainBar 
		var mainBar = [
			{text: 'Save', iconCls: 'dt-icon-save', handler:function(){this.fireEvent('save')}, scope: this}
		];
		
		//condition based on whether this form is an instance of an already instatiated record
		if(ic.instanceId){
			
			//username can not be changed
			username.disable();
			
			//show button to set password
			setpassword.show();
			
			//hide password field and label
			password.hide();
			
			//hide retypepassword field and label
			retypepassword.hide();
			
			is_active.enable();
			
			//add delete button
			mainBar.push({text: 'Delete', iconCls: 'dt-icon-delete', handler:function(){this.fireEvent('delete')}, scope: this});

			//Load server -> form values if we have the ic.instance_id
			var userid = ic.instanceId;
			this.form.form.url = 'users/'+userid+'.json';
		    this.form.load({method: 'GET'});
		}else{
			this.form.form.url = 'users'; 
		}
		
		//apply all components to this app instance
 		Ext.apply(this, {
 			items : this.form,
			mainBar : mainBar
 		});
 		
		//call App initComponent
		User.Form.superclass.initComponent.call(this);
		
		//hide fields that are not admin accessable
		var admincheck = Ext.util.Cookies.get('is_admin');
		if(admincheck != 'true'){
			is_admin.on('render',function(){
				is_admin.hide();
			});
			is_active.on('render',function(){
				is_active.hide();			
			});
		}
		
		//event handlers
		this.on('save',function(){
			var save_config = {scope: this};	
			var store = Ext.StoreMgr.get('user_index');
			if(ic.instanceId){
				save_config.params = {'_method':'PUT'};
				save_config.success = function(){
					if(store){store.reload();}
				}
			}else{
				save_config.success = function(form,action){
					this.destroy();
					Desktop.AppMgr.display('user_form',action.result.instanceId);
					if(store){store.reload();}
				}
			}
			this.form.getForm().submit(save_config);
		},this);
		
		this.on('delete',function(){
			Ext.Msg.confirm('Delete', 'Are you sure you want to delete User?',function(btn){
				if (btn == 'yes') {
					var userid = ic.instanceId;
					Ext.Ajax.request({
						url: 'users/' + userid + '.json',
						method: 'POST',
						success: function(){
							var store = Ext.StoreMgr.get('user_index');
							if(store){store.reload();}
							this.destroy();
						},
						params: {
							'_method': 'DELETE'
						},
						scope: this
					});
				}
			},this);
		},this);
 	}
});

Desktop.AppMgr.registerApp(User.Form, {
	title: 'Edit User',
	iconCls: 'dt-icon-user',
	appId: 'user_form',
	dockContainer: Desktop.CENTER
});
