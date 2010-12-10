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
    type_node = RDF_Resource.find_or_create(:uri_esc => RDF::GOLD.Termset.uri_esc)
    
    RDF_Statement.find_or_init(
      :subject => ts_node,
      :predicate_uri_esc => RDF.type.uri_esc,
      :object => type_node,
      :context => context_node
    ).save
    
    return ts_node
  end
  
  def set(args, context)
    self.set_label(args["rdfs:label"], context) if args.has_key?("rdfs:label")
    self.set_comment(args["rdfs:comment"], context) if args.has_key?("rdfs:comment")  
    
    return self
  end
  
  def set_label(label, context)
    label_node = RDF_Literal.find_or_create(:value => label, :lang => "en")
    
    old = RDF_Statement.find_by_quad(
      :subject => self,
      :predicate_uri_esc => RDF::RDFS.label.uri_esc,
      :context => context
    ).first   
    old.remove_context(context, {:object => true}) unless old.nil?
     
    RDF_Statement.find_or_init(
      :subject => self,
      :predicate_uri_esc => RDF::RDFS.label.uri_esc,
      :object => label_node,
      :context => context
    ).save 
  end

  
  def set_comment(comment, context)
    comment_node = RDF_Literal.find_or_create(:value => comment, :lang => "en")
    
    old = RDF_Statement.find_by_quad(
      :subject => self,
      :predicate_uri_esc => RDF::RDFS.comment.uri_esc,
      :context => context
    ).first  
    old.remove_context(context, {:object => true}) unless old.nil?
    
    RDF_Statement.find_or_init(
      :subject => self,
      :predicate_uri_esc => RDF::RDFS.comment.uri_esc,
      :object => comment_node,
      :context => context
    ).save
  end
  
  def copy_context(from_context, to_context)
    statements = RDF_Statement.find_by_quad(
      :subject => self,
      :context => from_context
    )

    statements.each do |st|
       st.contexts << to_context
    end
  end
  
  
  def remove_context(context)
    statements = RDF_Statement.find_by_quad(
      :subject => self,
      :context => context
    )
    
    statements.each do |st| 
      st.remove_context(context, {:subject => true, :object => true})
    end
    
  end
  
  

  
end