Ext.ns("SparqlWriter");

SparqlWriter.Panel = Ext.extend(Desktop.App, {
	frame: true,
	initComponent : function() {		
		var form = {
			xtype: 'form',
			items: [{
				xtype: 'textarea',
				hideLabel: true,
				height: 300,
				anchor: '100%'
			}],
			buttons: [{
				text: 'Run Query'
			}]
		};
		
 		Ext.apply(this, {
 			items : form
 		});
 		
 		SparqlWriter.Panel.superclass.initComponent.call(this);
 	}
});

Desktop.AppMgr.registerApp(SparqlWriter.Panel, {
	title: 'Sparql Writer',
	appId: 'sparqlwriter',
	iconCls: 'dt-icon-sparql',
	dockContainer: Desktop.CENTER,
	displayMenu: 'public'
});
