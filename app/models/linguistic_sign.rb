class LinguisticSign < RDF_Resource
  
  # Generates an escaped uri based on UUID timestamp algorithm
  #
  # @returns [String] uri
  def self.gen_uri_esc
    uuid = UUIDTools::UUID.timestamp_create.to_s
    "http://purl.org/linguistics/lingdesktop/linguistic_signs/#{uuid}".uri_esc
  end  
  
  
  def self.type
    RDF_Resource.find_or_create(:uri_esc => RDF::GOLD.LinguisticSign.uri_esc)
  end
  
  def language(context_node)
    @language ||= self.get_objects(RDF::GOLD.inLanguage => {:context => context_node}).first
  end
  
  def hasProperties(context_node)
    self.get_objects(RDF::GOLD.hasProperty => {:context => context_node})
  end
  
  def hasMeaning(context_node)
    @hasMeaning ||= self.get_objects(RDF::GOLD.hasMeaning => {:context => context_node}).first
  end
  
  
  def self.create_in_context(context_node, args = {})

    # find or create supporting graph
    node = LinguisticSign.create(:uri_esc => self.gen_uri_esc)
    
    RDF_Statement.find_or_init(
      :subject => node,
      :predicate_uri_esc => RDF.type.uri_esc,
      :object => self.type,
      :context => context_node
    ).save
    
    return node
  end

  
  def set_language(language_id, context_node)
    language_node = HumanLanguageVariety.find(:uri_esc => (RDF::LD.human_language_varieties.to_s + "/" + language_id).uri_esc)

    old = RDF_Statement.find_by_quad(
      :subject => self,
      :predicate_uri_esc => RDF::GOLD.inLanguage.uri_esc,
      :context => context_node
    ).first
    
    old.remove_context(context_node, {:object => true}) unless old.nil?
     
    RDF_Statement.find_or_init(
      :subject => self,
      :predicate_uri_esc => RDF::GOLD.inLanguage.uri_esc,
      :object => language_node,
      :context => context_node
    ).save 
  end
  
  def set_hasMeaning(meaning_uri, context_node)
    meaning_node = LexicalizedConcept.find(:uri_esc => meaning_uri.uri_esc)
    
    return if meaning_node.nil?

    old = RDF_Statement.find_by_quad(
      :subject => self,
      :predicate_uri_esc => RDF::GOLD.hasMeaning.uri_esc,
      :context => context_node
    ).first
    
    old.remove_context(context_node, {:object => true}) unless old.nil?
     
    RDF_Statement.find_or_init(
      :subject => self,
      :predicate_uri_esc => RDF::GOLD.hasMeaning.uri_esc,
      :object => meaning_node,
      :context => context_node
    ).save 
  end
  
  
  def set_hasProperty(property_uris, context_node)
    # clear current has meaning 
    RDF_Statement.find_by_quad(
      :subject => self,
      :predicate_uri_esc => RDF::GOLD.hasProperty.uri_esc,
      :context => context_node      
    ).each do |st|
      st.remove_context(context_node)
    end
    
    # replace with meaning_uris array from parameters
    JSON.parse(property_uris).each do |property_uri|
      property_node = RDF_Resource.find(:uri_esc => property_uri.uri_esc)
      
      RDF_Statement.find_or_init(
        :subject => self,
        :predicate_uri_esc => RDF::GOLD.hasProperty.uri_esc,
        :object => property_node,
        :context => context_node
      ).save
    end
  end
  
  def copy_context(from_context, to_context)
    super
    
    # copy context to terms
    self.hasMeaning(from_context).copy_context(from_context, to_context)
  end
end