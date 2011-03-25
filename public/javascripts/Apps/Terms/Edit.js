Ext.ns("Terms");

Terms.Edit = Ext.extend(Desktop.App, {
    frame: true,
    autoScroll: true,

    initComponent: function() {

        var ic = this.initialConfig;
        //configuration given to Desktop.App
        //setup fields
        var orthographicRep = new Ext.form.TextField({
            fieldLabel: 'Term Name',
            allowBlank: false,
            requiredField: true,
            name: 'rdfs:label',
            width: 165
        });
        
        var abbreviation = new Ext.form.TextField({
            fieldLabel: 'Abbreviation',
            name: 'gold:abbreviation',
            width: 165
        });

        var comment = new Ext.form.TextArea({
            height: 100,
            width: 685,
            fieldLabel: 'Comment',
            name: 'rdfs:comment'
        });

        //setup hasMeaningGrid GOLD Grid
        var hasMeaningGrid = new Ontology.DropGrid({
            height: 150,
            fieldLabel: 'Please select and drag a concept from the ontology to the space below',
            stripeRows: true,
            store: new Ext.data.JsonStore({
                // store configs
                autoDestroy: true,
                url: 'terms/' + ic.instanceId + '/hasMeaning.json',
                // reader configs
                root: 'data',
                idProperty: 'uri',
                fields: ['rdf:type', 'rdfs:comment', 'uri', 'rdfs:label', 'localname']
            }),
            colModel: new Ext.grid.ColumnModel({
                columns: [
                {
                    header: 'Label',
                    dataIndex: 'rdfs:label'
                },
                {
                    header: 'Definition',
                    dataIndex: 'rdfs:comment'
                }
                ]
            }),
        });


        //setup form
        this.form = new Ext.FormPanel({
            labelAlign: 'top',
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
                    items: orthographicRep
                },
                {
                    layout: 'form',
                    labelWidth: 90,
                    columnWidth: .5,
                    border: false,
                    items: abbreviation
                }]
            },
            comment, hasMeaningGrid]
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
            this.form.form.url = 'terms/' + id + '.json';
            this.form.load({
                method: 'GET'
            });

            hasMeaningGrid.getStore().load({
                method: 'GET'
            });
        } else {
            this.form.form.url = 'terms.json';
        }

        //apply all components to this app instance
        Ext.apply(this, {
            items: this.form,
            tbar: toolbar
        });
        
        //open helper apps
        Desktop.AppMgr.display('ontology_gold');

        //call App initComponent
        Terms.Edit.superclass.initComponent.call(this);

        //event handlers
        this.on('save',
        function() {
            var hasMeaningUris = hasMeaningGrid.store.collect('uri');
            var save_config = {
                scope: this,
                params: {
                    "gold:hasMeaning": Ext.encode(hasMeaningUris)
                }
            };
            
            if (ic.instanceId) {
                save_config.params['_method'] = 'PUT';
            }
            
            save_config.success = function(form, action) {
                var data = action.result.data;

                var terms_store = Ext.StoreMgr.get('terms_index');
                if (terms_store) {terms_store.reload();}
                
                Desktop.AppMgr.destroy('terms_view', ic.contextId, data.localname);
                Desktop.AppMgr.display(
                    'terms_view',
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
                        url: 'terms/' + ic.instanceId + '.json',
                        method: 'POST',
                        success: function() {
                            var terms_store = Ext.StoreMgr.get('terms_index');
                            if (terms_store) {terms_store.reload();}
                            //check to make sure the term nav is still open before refreshing
                            Desktop.AppMgr.destroy('terms_view', ic.contextId, ic.instanceId);
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

Desktop.AppMgr.registerApp(Terms.Edit, {
    title: 'Edit Term',
    iconCls: 'dt-icon-term',
    appId: 'terms_edit',
    dockContainer: Desktop.CENTER
});
