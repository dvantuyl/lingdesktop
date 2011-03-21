class LexicalItem < RDF_Resource
  
  # Generates an escaped uri based on UUID timestamp algorithm
  #
  # @returns [String] uri
  def self.gen_uri_esc
    uuid = UUIDTools::UUID.timestamp_create.to_s
    "http://purl.org/linguistics/lingdesktop/lexical_items/#{uuid}".uri_esc
  end  
  
  
  def self.type
    RDF_Resource.find_or_create(:uri_esc => RDF::GOLD.LexicalItem.uri_esc)
  end
  
  
  def self.create_in_context(context_node, args = {})

    # find or create supporting graph
    node = LexicalItem.create(:uri_esc => self.gen_uri_esc)
    
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
    self.set_memberOf(args["gold:memberOf"], context_node) if args.has_key?("gold:memberOf")
    return self
  end
  
  def set_memberOf(lexicon_id, context_node)
    lexicon_node = Lexicon.find(:uri_esc => (RDF::LD.lexicons.to_s + "/" + lexicon_id).uri_esc)

    old = RDF_Statement.find_by_quad(
      :subject => self,
      :predicate_uri_esc => RDF::GOLD.memberOf.uri_esc,
      :context => context_node
    ).first   
    old.remove_context(context_node, {:object => true}) unless old.nil?

    RDF_Statement.find_or_init(
      :subject => self,
      :predicate_uri_esc => RDF::GOLD.memberOf.uri_esc,
      :object => lexicon_node,
      :context => context_node
    ).save
  end
  
end