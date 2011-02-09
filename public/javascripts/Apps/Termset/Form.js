Ext.ns("Termsets");

Termsets.Form = Ext.extend(Desktop.App, {
    frame: true,
    autoScroll: true,

    initComponent: function() {

        var ic = this.initialConfig;
        //configuration given to Desktop.App
        //setup fields
        var label = new Ext.form.TextField({
            fieldLabel: 'What do you want to call your termset?',
            allowBlank: false,
            requiredField: true,
            name: 'rdfs:label',
            width: 165,
        });


        var comment = new Ext.form.TextArea({
            height: 100,
            width: 685,
            fieldLabel: 'Comment',
            name: 'rdfs:comment'
        });


        //setup form
        this.form = new Ext.FormPanel({
            labelAlign: 'top',
            frame: true,
            width: 700,
            baseParams: {
                format: 'json'
            },
            items: [{
                layout: 'column',
                border: false,
                items: [{
                    layout: 'form',
                    //labelWidth: 90,
                    columnWidth: .5,
                    border: false,
                    items: label
                }]
            },
            comment]
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
            this.form.form.url = 'termsets/' + id + '.json';
            this.form.load({
                method: 'GET'
            });
        } else {
            this.form.form.url = 'termsets';
        }



        //apply all components to this app instance
        Ext.apply(this, {
            items: this.form,
            tbar: toolbar
        });

        //call App initComponent
        Termsets.Form.superclass.initComponent.call(this);


        //event handlers
        this.on('save',
        function() {

            var save_config = {
                scope: this
            };
            //var store = Ext.StoreMgr.get('termset_index');

            if (ic.instanceId) {
                save_config.params = {
                    '_method': 'PUT'
                };
            }
            save_config.success = function(form, action) {
                if (ic.node.getOwnerTree()) {
                    ic.node.reload();
                }
                //check to make sure the term nav is still open before refreshing
                this.destroy();
            }
            this.form.getForm().submit(save_config);
        },
        this);

        this.on('delete',
        function() {
            Ext.Msg.confirm('Delete', 'Are you sure you want to delete?',
            function(btn) {
                if (btn == 'yes') {
                    var id = ic.instanceId;
                    Ext.Ajax.request({
                        url: 'termsets/' + id + '.json',
                        method: 'POST',
                        success: function() {
                            if (ic.node.getOwnerTree()) {
                                ic.node.reload();
                            }
                            //check to make sure the term nav is still open before refreshing
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

Desktop.AppMgr.registerApp(Termsets.Form, {
    title: 'Edit Term Set',
    iconCls: 'dt-icon-term',
    appId: 'termsets_form',
    dockContainer: Desktop.CENTER
});
