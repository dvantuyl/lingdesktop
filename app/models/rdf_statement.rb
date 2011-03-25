##
# RDF Named Graph Statement Node
#
#                           [RDF_Context context_one]       [RDF_Context context_two]
#                                     ^                               ^
#                                     \                             /
#                                      \                          / 
#                                   :context                 :context
#                                        \                    /
#                                         \                 /
#                                          \              /
#                                           \           /
#  [RDF_Resource subject]<---:subject---[RDF_Statement predicate]---:object--->[RDF_Literal object]
#
class RDF_Statement < Neo4j::Model
  
  property :predicate_uri_esc
  property :created_at
  
  has_n :contexts
  has_n :subject
  has_n :object
  has_n :created_by
  
  index :predicate_uri_esc
  
  def subject
    @subject ||= self.outgoing(:subject).first
  end
  
  
  def object
    @object ||= self.outgoing(:object).first
  end
  
  
  def predicate_uri
    self[:predicate_uri_esc].uri_unesc
  end
  
  def contexts
    @contexts ||= self.outgoing(:contexts).to_a
  end
  
  def created_by
    @created_by ||=self.outgoing(:created_by).first
  end
  
  def rdf
    if object.kind_of?(RDF_Literal)
      o = RDF::Literal.new(object.value, :language => object.lang)
    else
      o = RDF::URI.new(object.uri)
    end
    
    RDF::Statement.new({
      :subject => RDF::URI.new(subject.uri),
      :predicate => RDF::URI.new(predicate_uri),
      :object => o
    })
  end
  
  
  
  # Singleton method for initializing a RDF triple statement only if one isn't first found.
  # 
  # @param [Hash] the rdf quad to either find or create.
  # @option [RDF_Resource]              :subject    (nil)
  # @option [URI, #to_s]                :predicate
  # @option [RDF_Resource, RDF_Literal] :object     (nil)
  # @option [RDF_Context]               :context    (nil)   
  #
  # @return [RDF_Statement]
  #
  def self.find_or_init( args )
   
    # extract the args context option
    context = args[:context]
    raise "Context can not be nil" if context.nil?
    
    args.delete(:context)
    
    # first try to find the statement
    statement = RDF_Statement.find_by_quad( args ).first
    if !statement.nil? then    
      # add context to found statement
      statement.add_context context
    # if not found then create the statement
    else   
      statement = RDF_Statement.init_by_quad( args.merge({:context => context}) )
    end

    return statement
  end  
  
  
  def self.init_by_quad( args )
    s, p, o, c = args[:subject], args[:predicate_uri_esc], args[:object], args[:context]

    raise "Can not init statement without a subject" if s.nil?
    raise "Can not init statement without a predicate" if p.nil?
    raise "Can not init statement without an object" if o.nil?
    raise "Can not init statement without a context" if c.nil?


    #create statement and connect to subject and object
    statement = RDF_Statement.new(:predicate_uri_esc => p)
    statement.outgoing(:subject) << s
    statement.outgoing(:object) << o
    statement.add_context c
    statement.outgoing(:created_by) << c

    return statement
  end
  
  
  def self.find_by_quad( args )
    s, p, o, c = args[:subject], args[:predicate_uri_esc], args[:object], args[:context]
    
    statements = []
    
    #find by traversing from subject
    if !s.nil? then
      s.incoming(:subject).each do |statement|     
        next unless p.nil? || statement.predicate_uri_esc == p
        next unless o.nil? || statement.object == o
        next unless c.nil? || statement.contexts.include?(c)

        statements.push(statement)
      end
      
    #find by traversing from object
    elsif !o.nil? then
      o.incoming(:object).each do |statement|
        next unless p.nil? || statement.predicate_uri_esc == p
        next unless c.nil? || statement.contexts.include?(c)

        statements.push(statement)        
      end
      
    #find all statements with predicate
    elsif !p.nil? then
      RDF_Statement.all(:predicate_uri_esc => p).each do |statement|
        next unless c.nil? || statement.contexts.include?(c)
        statements.push(statement)
      end    
    end

    return statements 
  end
  
  def add_context(context_node)

    # add context if not already added 
    if !self.contexts.include?(context_node) then
         
      self.outgoing(:contexts) << context_node
      self.save
      #recursivily add followers contexts
      context_node.followers.each {|follower| self.add_context(follower)}
    end  
  end
  
  def remove_context(context_node, cleanup = {})    

    # remove context if not already removed 
    if self.contexts.include?(context_node) then
      
      #remove context from statement 
      self.rels.to_other(context_node).del
    
      # if this statement has no contexts
      if self.contexts.empty? then
        s = self.subject
        o = self.object
      
        #destroy this statement
        self.destroy
      
        # destroy subject and object if they don't have any statements
        s.destroy if (s.rels.empty? && cleanup.has_key?(:subject) && cleanup[:subject])
        o.destroy if (o.rels.empty? && cleanup.has_key?(:object) && cleanup[:object])
        
      #recursivily remove followers contexts  
      else
        context_node.followers.each {|follower| self.remove_context(follower, cleanup)}
      end
    end
  end
end