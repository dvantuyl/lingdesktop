Ext.ns("Term");

Term.Form = Ext.extend(Desktop.App, {
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
            width: 165,
        });
        
        var abbreviation = new Ext.form.TextField({
            fieldLabel: 'Abbreviation',
            name: 'gold:abbreviation',
            width: 165,
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
            fieldLabel: 'Please select and drag a concept from the ontology to the space below.',
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


        //setup mainBar
        var mainBar = [
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
            mainBar.push({
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
            mainBar: mainBar
        });

        //call App initComponent
        User.Form.superclass.initComponent.call(this);

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
            
            if (ic.node) {
                save_config.params["gold:memberOf"] = ic.node.attributes.uri
            }
            
            if (ic.instanceId) {
                save_config.params['_method'] = 'PUT';
            }
            
            save_config.success = function() {
                if (ic.node && ic.node.getOwnerTree()) {
                    ic.node.getLoader().load(ic.node);
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
                    
                    Ext.Ajax.request({
                        url: 'terms/' + ic.instanceId + '.json',
                        method: 'POST',
                        success: function() {
                            if (ic.node && ic.node.getOwnerTree()) {
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

Desktop.AppMgr.registerApp(Term.Form, {
    title: 'Edit Term',
    iconCls: 'dt-icon-term',
    appId: 'term_form',
    dockContainer: Desktop.CENTER
});
