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
  
  def linguistic_sign(context_node)
    @linguistic_sign ||= _linguistic_sign(context_node)
  end
  
  
  def _linguistic_sign(context_node)
    ls_node = self.get_objects(RDF::GOLD.hasLinguisticSign => {:context => context_node}).first
    
    ls_node ||= LinguisticSign.create_in_context(context_node)
    
    RDF_Statement.find_or_init(
      :subject => self,
      :predicate_uri_esc => RDF::GOLD.hasLinguisticSign.uri_esc,
      :object => ls_node,
      :context => context_node
    ).save
    
    ls_node
  end
  
   
  def set(args, context_node)
    self.set_label(args["rdfs:label"], context_node) if args.has_key?("rdfs:label")
    self.set_comment(args["rdfs:comment"], context_node) if args.has_key?("rdfs:comment")
    self.set_memberOf(args[:lexicon_id], context_node) if args.has_key?(:lexicon_id)
    linguistic_sign(context_node).set_language(args["gold:inLanguage"], context_node) if args.has_key?("gold:inLanguage")
    linguistic_sign(context_node).set_hasProperty(args["gold:hasProperty"], context_node) if args.has_key?("gold:hasProperty")
    linguistic_sign(context_node).set_hasMeaning(args["gold:hasMeaning"], context_node) if args.has_key?("gold:hasMeaning")
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
  
  def copy_context(from_context, to_context)
    super
    
    # copy context to terms
    self.linguistic_sign(from_context).copy_context(from_context, to_context)
  end
  
  def remove_context(context_node)

    
    # remove context from terms
    self.linguistic_sign(context_node).remove_context(context_node)
    
    super(context_node)
   
  end

end