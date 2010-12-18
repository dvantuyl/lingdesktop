class Group < RDF_Context
  
  property :name, :comment
  
  index :name
  
  validates :name, :presence => true

  

  def self.gen_uri_esc
    uuid = UUIDTools::UUID.timestamp_create.to_s
    "http://purl.org/linguistics/lingdesktop/groups/#{uuid}".uri_esc
  end
  
  
  def set(args)
    self.set_members(args["members"]) if args.has_key?("members")
    self.name = args["name"] if args.has_key?("name")   
    self.comment = args["comment"] if args.has_key?("comment")
    return self
  end
  
  

  
  

  
end