class Term < RDF_Resource
  
  # Generates an escaped uri based on UUID timestamp algorithm
  #
  # @returns [String] uri
  def self.gen_uri_esc
    uuid = UUIDTools::UUID.timestamp_create.to_s
    "http://purl.org/linguistics/lingdesktop/terms/#{uuid}".uri_esc
  end  
  
  
  def self.type
    RDF_Resource.find_or_create(:uri_esc => RDF::GOLD.Term.uri_esc)
  end
  
  
  def self.create_in_context(context_node, args = {})

    # find or create supporting graph
    term_node = Term.create(:uri_esc => self.gen_uri_esc)
    
    RDF_Statement.find_or_init(
      :subject => term_node,
      :predicate_uri_esc => RDF.type.uri_esc,
      :object => self.type,
      :context => context_node
    ).save
    
    return term_node.set(args, context_node)
  end
  
  
  def set(args, context_node)
    self.set_label(args["rdfs:label"], context_node) if args.has_key?("rdfs:label")
    self.set_comment(args["rdfs:comment"], context_node) if args.has_key?("rdfs:comment")
    self.set_abbreviation(args["gold:abbreviation"], context_node) if args.has_key?("gold:abbreviation")
    self.set_hasMeaning(args["gold:hasMeaning"], context_node) if args.has_key?("gold:hasMeaning")
    self.set_memberOf(args["gold:memberOf"], context_node) if args.has_key?("gold:memberOf")    
    
    return self
  end
  
  def set_abbreviation(abbreviation, context_node)
    abbrv_node = RDF_Literal.find_or_create(:value => abbreviation, :lang => "en")
    
    old = RDF_Statement.find_by_quad(
      :subject => self,
      :predicate_uri_esc => RDF::GOLD.abbreviation.uri_esc,
      :context => context_node
    ).first   
    old.remove_context(context_node, {:object => true}) unless old.nil?
    
    RDF_Statement.find_or_init(
      :subject => self,
      :predicate_uri_esc => RDF::GOLD.abbreviation.uri_esc,
      :object => abbrv_node,
      :context => context_node
    ).save
  end
  
  def set_hasMeaning(meaning_uris, context_node)
    # clear current has meaning 
    RDF_Statement.find_by_quad(
      :subject => self,
      :predicate_uri_esc => RDF::GOLD.hasMeaning.uri_esc,
      :context => context_node      
    ).each do |st|
      st.remove_context(context_node)
    end
    
    # replace with meaning_uris array from parameters
    JSON.parse(meaning_uris).each do |meaning_uri|
      meaning_node = RDF_Resource.find(:uri_esc => meaning_uri.uri_esc)
      
      RDF_Statement.find_or_init(
        :subject => self,
        :predicate_uri_esc => RDF::GOLD.hasMeaning.uri_esc,
        :object => meaning_node,
        :context => context_node
      ).save
    end
  end
  
  def set_memberOf(termset_uri, context_node)
    termset_node = Termset.find(:uri_esc => termset_uri.uri_esc)

    RDF_Statement.find_or_init(
      :subject => self,
      :predicate_uri_esc => RDF::GOLD.memberOf.uri_esc,
      :object => termset_node,
      :context => context_node
    ).save
  end
  
end