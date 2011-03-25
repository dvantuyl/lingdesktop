Ext.ns("LexicalizedConcepts");

LexicalizedConcepts.Edit = Ext.extend(Desktop.App, {
    frame: true,
    autoScroll: true,

    initComponent: function() {     
        var ic = this.initialConfig;
        
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
            url: 'lexicalized_concepts',
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
            this.form.form.url = 'lexicalized_concepts/' + id + '.json';
            this.form.load({
                method: 'GET'
            });

        } else {
            this.form.form.url = 'lexicalized_concepts.json';
        }

        //apply all components to this app instance
        Ext.apply(this, {
            items: this.form,
            tbar: toolbar
        });

        //call App initComponent
        LexicalizedConcepts.Edit.superclass.initComponent.call(this);

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

            save_config.success = function(form, action) {
                var data = action.result.data;
                

                var lexicalized_concepts_store = Ext.StoreMgr.get('lexicalized_concepts_index');
                if (lexicalized_concepts_store) {
                    lexicalized_concepts_store.reload();
                }
                
                Desktop.AppMgr.display(
                    'lexicalized_concepts_view',
                    data.localname,
                    {
                        title : data["rdfs:label"],
                        contextId : ic.contextId
                    }
                );
                
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

                    Ext.Ajax.request({
                        url: 'lexicalized_concepts/' + ic.instanceId + '.json',
                        method: 'POST',
                        success: function() {
                            var lexicalized_concepts_store = Ext.StoreMgr.get('lexicalized_concepts_index');
                            if (lexicalized_concepts_store) {
                                lexicalized_concepts_store.reload();
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

Desktop.AppMgr.registerApp(LexicalizedConcepts.Edit, {
    title: 'Edit Lexicalized_concept',
    iconCls: 'dt-icon-lexicalized_concepts',
    appId: 'lexicalized_concepts_edit',
    dockContainer: Desktop.CENTER
});

