class Lexicon < RDF_Resource
  
  # Generates an escaped uri based on UUID timestamp algorithm
  #
  # @returns [String] uri
  def self.gen_uri_esc
    uuid = UUIDTools::UUID.timestamp_create.to_s
    "http://purl.org/linguistics/lingdesktop/lexicons/#{uuid}".uri_esc
  end  
  
  
  def self.type
    RDF_Resource.find_or_create(:uri_esc => RDF::GOLD.Lexicon.uri_esc)
  end
  
  def lexical_items(context_node)
    self.get_subjects(RDF::GOLD.memberOf => {:context => context_node})
  end
  
  def self.create_in_context(context_node, args = {})

    # find or create supporting graph
    lexicon_node = Lexicon.create(:uri_esc => self.gen_uri_esc)
    
    RDF_Statement.find_or_init(
      :subject => lexicon_node,
      :predicate_uri_esc => RDF.type.uri_esc,
      :object => self.type,
      :context => context_node
    ).save
    
    return lexicon_node.set(args, context_node)
  end
  
   
  def set(args, context_node)
    self.set_label(args["rdfs:label"], context_node) if args.has_key?("rdfs:label")
    self.set_comment(args["rdfs:comment"], context_node) if args.has_key?("rdfs:comment")  
    return self
  end
  
  def copy_context(from_context, to_context)
    super
    
    # copy context to terms
    self.lexical_items(from_context).each {|item| item.copy_context(from_context, to_context)}
  end
  
  def remove_context(context_node)

    
    # remove context from terms
    self.lexical_items(context_node).each {|item| item.remove_context(context_node)}
    
    super(context_node)
   
  end
  
end