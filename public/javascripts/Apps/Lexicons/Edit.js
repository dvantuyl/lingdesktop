Ext.ns("Lexicons");

Lexicons.Edit = Ext.extend(Desktop.App, {
    frame: true,
    autoScroll: true,

    initComponent: function() {

        var ic = this.initialConfig;
        //configuration given to Desktop.App
        //setup fields
        var name = new Ext.form.TextField({
            fieldLabel: 'Name',
            allowBlank: false,
            requiredField: true,
            name: 'rdfs:label',
            width: 165
        });

        var description = new Ext.form.TextArea({
            height: 100,
            width: 685,
            fieldLabel: 'Description',
            name: 'rdfs:comment'
        });

        //setup form
        this.form = new Ext.FormPanel({
            labelAlign: 'top',
            frame: true,
            width: 700,
            url: 'lexicons',
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
            description]
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
            this.form.form.url = 'lexicons/' + id + '.json';
            this.form.load({
                method: 'GET'
            });

        } else {
            this.form.form.url = 'lexicons.json';
        }

        //apply all components to this app instance
        Ext.apply(this, {
            items: this.form,
            tbar: toolbar
        });

        //call App initComponent
        Lexicons.Edit.superclass.initComponent.call(this);

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

                var lexicons_store = Ext.StoreMgr.get('lexicons_index');
                if (lexicons_store) {
                    lexicons_store.reload();
                }
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
                        url: 'lexicons/' + ic.instanceId + '.json',
                        method: 'POST',
                        success: function() {
                            var lexicons_store = Ext.StoreMgr.get('lexicons_index');
                            if (lexicons_store) {
                                lexicons_store.reload();
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

Desktop.AppMgr.registerApp(Lexicons.Edit, {
    title: 'Edit Lexicon',
    iconCls: 'dt-icon-lexicons',
    appId: 'lexicons_edit',
    dockContainer: Desktop.CENTER
});

