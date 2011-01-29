Ext.ns("Groups");

Groups.DropGrid = Ext.extend(Ext.grid.GridPanel, {
	enableDragDrop : true,
	
	initComponent : function(){
		
		var _this = this;
		
		var viewConfig = {forceFit: true};
		
		var selectionModel = new Ext.grid.RowSelectionModel({singleSelect:true});
		
		var tbar =  [{
			text: 'View',
			iconCls: 'dt-icon-view',
			handler: function(){
				var record = selectionModel.getSelected();
				var name = record.get('name');
				var id = record.get('id');
		
				Desktop.AppMgr.display('contexts_view', id, {title: name});
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
		
		Groups.DropGrid.superclass.initComponent.call(this);
		
		this.on('rowdblclick', function(g, index){
			var record = selectionModel.getSelected();
			var name = record.get('name');
			var id = record.get('id');
	
			Desktop.AppMgr.display('contexts_view', id, {title: name});
		});
		
		this.on('render', function(){
		  dropZoneOverrides.ddGroup = 'community';
			var hasMeaningDZCfg = Ext.apply({},dropZoneOverrides, {
				grid : _this
			});
			new Ext.dd.DropZone(_this.el, hasMeaningDZCfg);	
		});
		
		this.on('datadrop', function(store, data){
			if (!store.getById(data.id.toString()) // dont allow context that's already been added
			  && (!_this.groupId || _this.groupId != data.id)) { //dont allow group to follow this group
			  
				var p = new store.recordType(data, data.name); // create new record
				store.insert(0, p); // insert a new record into the store (also see add)
			}
        	Desktop.AppMgr.setFocused(_this);			
		});
	}
});
