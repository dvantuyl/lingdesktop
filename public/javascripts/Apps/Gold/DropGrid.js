Ext.ns("Ontology.DropGrid");

Ontology.DropGrid = Ext.extend(Ext.grid.GridPanel, {
	enableDragDrop : true,
	ddGroup : 'resource',
	
	initComponent : function(){
		
		var _this = this;
		
		var viewConfig = {forceFit: true};
		
		var selectionModel = new Ext.grid.RowSelectionModel({singleSelect:true});
		
		var tbar =  [{
			text: 'View',
			iconCls: 'dt-icon-view',
			handler: function(){
				var record = selectionModel.getSelected();
				var label = record.get('RDF_label');
				var sid = record.get('sid');
				var localname = record.get('localname');
		
				Desktop.AppMgr.display(
					'ontology_class_view', 
					localname, 
					{sid: sid, title: label}
				);
			}
		},{
			text: 'Remove',
			iconCls: 'dt-icon-delete',
			handler: function(){
				var record = selectionModel.getSelected();
				_this.getStore().remove(record);
			}
		}];
		
		Ext.apply(this, {
			viewConfig : viewConfig,
			sm : selectionModel,
			tbar : tbar
		});
		
		Ontology.DropGrid.superclass.initComponent.call(this);
		
		this.on('rowdblclick', function(g, index){
			var record = g.getStore().getAt(index);
			var label = record.get('RDFS_label');
			var sid = record.get('sid');
			var localname = record.get('localname');
	
			Desktop.AppMgr.display(
				'ontology_class_view', 
				localname, 
				{sid: sid, title: label}
			);
		});
		
		this.on('render', function(){
		  dropZoneOverrides.ddGroup = 'gold';
			var hasMeaningDZCfg = Ext.apply({},dropZoneOverrides, {
				grid : _this
			});
			new Ext.dd.DropZone(_this.el, hasMeaningDZCfg);	
		});
		
		this.on('datadrop', function(store, data){
			if (!store.getById(data.uri)) {
				var p = new store.recordType(data, data.localname); // create new record
				store.insert(0, p); // insert a new record into the store (also see add)
			}
        	Desktop.AppMgr.setFocused(_this);			
		});
	}
});
