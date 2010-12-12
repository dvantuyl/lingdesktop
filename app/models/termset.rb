class Termset < RDF_Resource
  
  # Generates an escaped uri based on UUID timestamp algorithm
  #
  # @returns [String] uri
  def self.gen_uri_esc
    uuid = UUIDTools::UUID.timestamp_create.to_s
    "http://purl.org/linguistics/lingdesktop/termsets/#{uuid}".uri_esc
  end  
  
  
  def self.type
    RDF_Resource.find_or_create(:uri_esc => RDF::GOLD.Termset.uri_esc)
  end
  
  
  def self.create_in_context(context_node)

    # find or create supporting graph
    ts_node = Termset.create(:uri_esc => self.gen_uri_esc)
    
    RDF_Statement.find_or_init(
      :subject => ts_node,
      :predicate_uri_esc => RDF.type.uri_esc,
      :object => self.type,
      :context => context_node
    ).save
    
    return ts_node
  end
  
  
  def terms(context_node)
    self.get_subjects(RDF::GOLD.memberOf => {:context => context_node})
  end
   
  
  def set(args, context_node)
    self.set_label(args["rdfs:label"], context_node) if args.has_key?("rdfs:label")
    self.set_comment(args["rdfs:comment"], context_node) if args.has_key?("rdfs:comment")  
    return self
  end
  
  
  def copy_context(from_context, to_context)

    # copy context to terms
    self.terms(from_context).each{|term| term.copy_context(from_context, to_context)}
   
    self.copy_context!(from_context, to_context)
  end
  
  
  def remove_context(context_node)
    
    # remove context from terms
    self.terms(context_node).each{|term| term.remove_context(context_node)}
    
    self.remove_context!(context_node)   
  end
end