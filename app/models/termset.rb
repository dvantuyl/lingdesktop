class Termset < RDF_Resource
  
  # Generates an escaped uri based on UUID timestamp algorithm
  #
  # @returns [String] uri
  def self.gen_uri_esc
    uuid = UUIDTools::UUID.timestamp_create.to_s
    "http://purl.org/linguistics/lingdesktop/termsets/#{uuid}".uri_esc
  end  
  
  
  def self.create_in_context(context_node)

    # find or create supporting graph
    ts_node = Termset.create(:uri_esc => Termset.gen_uri_esc)
    type_node = RDF_Resource.find(:uri_esc => RDF::GOLD.Termset.uri_esc)
    RDF_Statement.create_by_quad(
      :subject => ts_node,
      :predicate_uri_esc => RDF.type.uri_esc,
      :object => type_node,
      :context => context_node
    )
    
    return ts_node
  end
  
  def set(context, args)
    self.set_label(context, args["rdfs:label"]) if args.has_key?("rdfs:label")
    self.set_comment(context, args["rdfs:comment"]) if args.has_key?("rdfs:comment")  
    
    return self
  end
  
  def set_label(context, label)
    label_node = RDF_Literal.find_or_create(:value => label, :lang => "en")    
    RDF_Statement.create_by_quad(
      :subject => self,
      :predicate_uri_esc => RDF::RDFS.label,
      :object => label_node,
      :context => context
    ) 
  end
  
  def set_comment(context, comment)
    comment_node = RDF_Literal.find_or_create(:value => comment, :lang => "en")
    RDF_Statement.create_by_quad(
      :subject => self,
      :predicate_uri_esc => RDF::RDFS.comment,
      :object => comment_node,
      :context => context
    )
  end
  
  

  
end