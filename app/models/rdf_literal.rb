class RDF_Literal < Neo4j::Model

  property :value
  property :lang
  property :created_at, :type => DateTime

  index :value
  index :lang
  
  validates_presence_of :value
  validates_presence_of :lang
  
  #validates_uniqueness_of :value, :scope => :lang

  def to_hash(args = [])
    {:value => self.value, :lang => self.lang}
  end


  def self.find_or_create(args)
    lang = args[:lang]
    value = args[:value]
    RDF_Literal.all("lang: #{lang} AND value: \"#{value}\"").first || RDF_Literal.create(:lang => lang, :value => value)   
  end

end
