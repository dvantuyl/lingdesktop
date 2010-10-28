class CTX_Context
  include Neo4j::NodeMixin

  property :uri

  index :uri

  def self.find_or_create(uri)
    return CTX_Context.find(:uri => uri).first || CTX_Context.new(:uri => uri)
  end

end