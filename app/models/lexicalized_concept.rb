class LexicalizedConcept < RDF_Resource
  
  # Generates an escaped uri based on UUID timestamp algorithm
  #
  # @returns [String] uri
  def self.gen_uri_esc
    uuid = UUIDTools::UUID.timestamp_create.to_s
    "http://purl.org/linguistics/lingdesktop/lexicalized_concepts/#{uuid}".uri_esc
  end  
  
  
  def self.type
    RDF_Resource.find_or_create(:uri_esc => RDF::GOLD.LexicalizedConcept.uri_esc)
  end
  
  
  def self.create_in_context(context_node, args = {})

    # find or create supporting graph
    node = LexicalizedConcept.create(:uri_esc => self.gen_uri_esc)
    
    RDF_Statement.find_or_init(
      :subject => node,
      :predicate_uri_esc => RDF.type.uri_esc,
      :object => self.type,
      :context => context_node
    ).save
    
    return node.set(args, context_node)
  end
  
   
  def set(args, context_node)
    self.set_label(args["rdfs:label"], context_node) if args.has_key?("rdfs:label")
    self.set_comment(args["rdfs:comment"], context_node) if args.has_key?("rdfs:comment")  
    return self
  end
  
end