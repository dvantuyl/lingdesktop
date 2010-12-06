class RDF_Resource < Neo4j::Rails::Model

  property :uri_esc
  property :created_at

  index :uri_esc
  
  validates :uri_esc, :presence => true, :uniqueness => true

  def self.find_or_create(args) 
    return RDF_Resource.find(args) || RDF_Resource.create(args)
  end

  def localname
    self.uri.gsub(/([^\/]*\/|[^#]*#)/, "")
  end
  
  def uri
    self[:uri_esc].uri_unesc
  end

  def to_hash(predicates = [])
    predicates = [] if predicates.nil?
    
    resource_hash = {
      :uri => self.uri,
      :localname => self.localname}

    predicates.each do |key, args|
      result = nil
      
      # use predicate option if given
      if args.has_key?(:predicate) then
        predicate = args[:predicate]
      
      # else extract predicate from key
      else
        ns, val = key.split(':')
        predicate = eval("RDF" + (ns == "rdf" ? ".#{val}" : "::#{ns.upcase}.#{val}")) #note that the eval string calls the RDF.rb lib
      end
    
      # get subjects
      if args[:subjects] then
        result =  self.get_subjects(predicate => args)
      
      # get objects
      else
        result = self.get_objects(predicate => args)
      end

      # handle array result
      if result.kind_of?(Array) then
        resource_hash.merge!({key => result.collect{|r| r.to_hash(args[:args])}})

      # handle boolean result
      elsif result.kind_of?(TrueClass) || result.kind_of?(FalseClass) then
        resource_hash.merge!({key => result})

      # handle string result
      elsif result.kind_of?(String) then
        resource_hash.merge!({key => result})

      # handle rdf result
      elsif !result.nil?
        resource_hash.merge!({key => result.to_hash(args[:args])})
      end
    end

    return resource_hash
  end
  
  def get_subjects(predicate_and_args)
    predicate, args = predicate_and_args.first
    
    #collect subjects
    result = RDF_Statement.find_by_quad(
      :subject => nil, 
      :predicate_uri_esc => predicate.uri_esc, 
      :object => self,
      :context => args[:context]
    ).collect {|st| st.subject}
    
    #filter
    RDF_Resource.filter_results(result, args)
  end

  # Finds objects where self is subject and matches against arg conditions
  # 
  # @param [String => Hash] predicate uri => hash arguments
  #
  # @return [mixed]
  #
  def get_objects(predicate_and_args)
    predicate, args = predicate_and_args.first
    
    #collect objects
    result = RDF_Statement.find_by_quad(
      :subject => self, 
      :predicate_uri_esc => predicate.uri_esc, 
      :object => nil, 
      :context => args[:context]
    ).collect {|st| st.object}
    
    #filter
    RDF_Resource.filter_results(result, args)
  end
  
  
  private
  
  # Filters a node array by the argument options
  #
  # @param [Array] Array of Neo4j nodes
  #
  # @param [Hash] 
  # @option [String]  :lang (nil) 
  #   the languange of node
  # @option [Symbol]  :simple_value  (nil)
  #   property of node to return instead of full node
  # @option [Boolean] :first (nil)
  #   return the first node
  # @option [Boolean] :boolean_xor
  #   XOR on whether result is empty or not
  #
  # @return [mixed]
  def self.filter_results(result, args)
    
    result = self.filter_by_lang(result, args[:lang]) if args.has_key?(:lang)
    result = self.filter_simple_value(result, args[:simple_value]) if args.has_key?(:simple_value)
    result = self.filter_first(result) if args.has_key?(:first)
    result = self.filter_empty_xor(result, args[:empty_xor]) if args.has_key?(:empty_xor)
    
    return result
  end
  
  def self.filter_by_lang(result = [], lang = "")    
    result.delete_if{|node| !node.property?(:lang) || (node.lang != lang)}.compact
  end
  
  def self.filter_simple_value(result = [], property = nil)
    result.delete_if do |node| 
      !node.property?(property.to_s)
    end.compact.collect{|node| node[property]}  
  end
  
  def self.filter_first(result = [])
    result.first
  end
  
  def self.filter_empty_xor(result = [], empty_xor = true)
    result.empty? ^ empty_xor
  end
  


end