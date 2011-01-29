Ext.ns("Ontology");

Ontology.Tree = Ext.extend(Ext.tree.TreePanel, {
	rootVisible: false,
	autoScroll: true,
	enableDrag : true,
	ddGroup : 'gold',
	initComponent : function(){
		var ic = this.initialConfig;
		
		//set dummy root
		var root = new Ext.tree.AsyncTreeNode({
			text: 'Invisible Root',
			draggable: false,
			localname: ic.localname,
			sid: ic.sid
		});
		
		//init tree loader
		var loader = new Ext.tree.TreeLoader({
			url: 'gold/'+ic.localname+'/subclasses.json',
			requestMethod: 'GET'
		});
		
		var view_btn = {
			xtype: 'button',
			text: 'View',
			handler: function(){
				var node = this.getSelectionModel().getSelectedNode();
				var text = node.attributes.text;
				var sid = node.attributes.sid;
				var localname = node.attributes.localname;
				
				//open tree in new ontology_nav
				Desktop.AppMgr.display(
					'ontology_class_view', 
					node.attributes.localname, 
					{sid: sid, title: text}
				);	
				
				//hide context menu
				node.getOwnerTree().contextMenu.hide();			
			},
			scope: this
		}
		
		//button extracts the selected node's attributes and creates a new tree in another tab
		var expand_to_tab = {
			xtype:'button',
			text: 'Expand to Tab', 
			handler: function(){ 
				//extract node attributes
				var node = this.getSelectionModel().getSelectedNode();
				var text = node.attributes.text;
				var sid = node.attributes.sid;
				var localname = node.attributes.localname;
				var roots = [{localname: localname,title: text}];
				
				//open tree in new ontology_nav
				Desktop.AppMgr.display(
					'ontology_nav', 
					node.attributes.text, 
					{sid: sid, roots: roots}
				);
				
				//hide context menu
				node.getOwnerTree().contextMenu.hide();
			},
			scope: this
		};
		
		
		//right click menu
		var contextMenu = new Ext.menu.Menu({
			items: [view_btn, expand_to_tab]
		});
		
		Ext.apply(this, {
			contextMenu: contextMenu,
 			root: root,
			loader: loader
 		});
 		
 		Ontology.Tree.superclass.initComponent.call(this);
		
		//set the tree base params to the node attributes
		loader.on("beforeload", function(treeLoader, node) {
			treeLoader.url = 'gold/'+node.attributes.localname+'/subclasses.json'
			treeLoader.baseParams.sid = node.attributes.sid;
    	}, this);
		
		//on right click
		this.on("contextmenu", function(node, e){
			// Register the context node with the menu so that a Menu Item's handler function can access
			// it via its parentMenu property.
            if(!node.leaf){
				node.select();
	            var c = node.getOwnerTree().contextMenu;
	            c.contextNode = node;
	            c.showAt(e.getXY());
			}
		}, this);
		
		this.on('click', function(node, e){
			this.ownerCt.fireEvent('nodeclick', node, e);
		},this);
		
		this.on('dblclick', function(node, e){
			var node = this.getSelectionModel().getSelectedNode();
			var text = node.attributes.text;
			var sid = node.attributes.sid;
			var localname = node.attributes.localname;
			
			//open tree in new ontology_nav
			Desktop.AppMgr.display(
				'ontology_class_view', 
				node.attributes.localname, 
				{sid: sid, title: text}
			);		
		},this);
		
		this.on('deactivate', function(){
			this.ownerCt.fireEvent('tree-deactivate');
		},this);
	}
});
