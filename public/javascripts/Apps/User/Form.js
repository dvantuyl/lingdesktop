Ext.ns("User");

User.Form = Ext.extend(Desktop.App, {
    frame: true,
    autoScroll: true,

    initComponent: function() {

        var ic = this.initialConfig;
        //configuration given to Desktop.App
        //setup fields
        var name = new Ext.form.TextField({
            fieldLabel: 'Name',
            name: 'name',
            width: 165,
        });

        var email = new Ext.form.TextField({
            fieldLabel: 'Email',
            name: 'email',
            width: 165,
            regex: /^([\w\-\'\-]+)(\.[\w-\'\-]+)*@([\w\-]+\.){1,5}([A-Za-z]){2,4}$/
        });

        var password = new Ext.form.TextField({
            fieldLabel: 'Password',
            name: 'password',
            itemId: 'password',
            inputType: 'password',
            width: 165,
            validator: function(value) {
                return ((password.hidden || value.length >= 5) ? true: "Password must be at least 5 characters long")
            }
        });

        var retypepassword = new Ext.form.TextField({
            fieldLabel: 'Retype Password',
            name: 'password_confirmation',
            inputType: 'password',
            width: 165,
            validator: function(value) {
                return ((password.getValue() == value) ? true: "Password does not match");
            }
        });

        var setpassword = new Ext.Button({
            hidden: true,
            text: 'Set Password',
            handler: function() {
                password.enable();
                password.show();
                retypepassword.show();
                setpassword.hide();
            }
        });

        var hidden_admin = new Ext.form.Hidden({
            name: 'is_admin'
        });

        var hidden_public = new Ext.form.Hidden({
            name: 'is_public'
        });

        var is_admin = new Ext.form.Checkbox({
            fieldLabel: 'Administrator',
            name: 'is_admin',
            hidden: true,
            submitValue: false,
            handler: function(chkbox, checked) {
                hidden_admin.setValue(checked);
            }
        });
        
        var is_public = new Ext.form.Checkbox({
            fieldLabel: 'Public',
            name: 'is_public',
            submitValue: false,
            handler: function(chkbox, checked) {
                hidden_public.setValue(checked);
            }
        });
        
        var description = new Ext.form.TextArea({
            height: 100,
            width: 685,
            fieldLabel: 'Description',
            name: 'description'
        });

        //setup form
        this.form = new Ext.FormPanel({
            frame: true,
            width: 700,
            url: 'users',
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
                    items: [
                    name,
                    email,
                    is_public,
                    hidden_public,
                    ]
                },
                {
                    layout: 'form',
                    labelWidth: 120,
                    columnWidth: .5,
                    border: false,
                    trackLabels: true,
                    items: [
                    setpassword,
                    password,
                    retypepassword,
                    is_admin,
                    hidden_admin
                    ]
                }]
            },description]
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

            //username can not be changed
            email.disable();

            //show button to set password
            setpassword.show();

            //hide password field and label
            password.hide();

            //hide retypepassword field and label
            retypepassword.hide();

            //add delete button
            // mainBar.push({text: 'Delete', iconCls: 'dt-icon-delete', handler:function(){this.fireEvent('delete')}, scope: this});
            //Load server -> form values if we have the ic.instance_id
            var userid = ic.instanceId;
            this.form.form.url = 'users/' + userid + '.json';
            this.form.load({
                method: 'GET'
            });
        } else {
            this.form.form.url = 'users';
        }

        //apply all components to this app instance
        Ext.apply(this, {
            items: this.form,
            tbar: toolbar
        });

        //call App initComponent
        User.Form.superclass.initComponent.call(this);

        //hide fields that are not admin accessable
        var current_user = Desktop.workspace.getCurrentUser();
        if (current_user.is_admin) {
            is_admin.on('render',
            function() {
                is_admin.show();
            });
        }

        //event handlers
        this.on('save',
        function() {
            var save_config = {
                scope: this
            };
            
            if (ic.instanceId) {
                save_config.params = {
                    '_method': 'PUT'
                };
            }
            
            save_config.success = function() {
                this.destroy();
                
                Desktop.AppMgr.display('user_index');
                
                var users_store = Ext.StoreMgr.get('users_index');
                if (users_store) {users_store.reload();}

                var community_store = Ext.StoreMgr.get('community_index');
                if (community_store) {community_store.reload();}
            }
            
            this.form.getForm().submit(save_config);
        },
        this);

        this.on('delete',
        function() {
            Ext.Msg.confirm('Delete', 'Are you sure you want to delete User?',
            function(btn) {
                if (btn == 'yes') {
                    var userid = ic.instanceId;
                    Ext.Ajax.request({
                        url: 'users/' + userid + '.json',
                        method: 'POST',
                        success: function() {
                            var store = Ext.StoreMgr.get('user_index');
                            if (store) {
                                store.reload();
                            }
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
    }
});

Desktop.AppMgr.registerApp(User.Form, {
    title: 'Edit User',
    iconCls: 'dt-icon-user',
    appId: 'user_form',
    dockContainer: Desktop.CENTER
});
