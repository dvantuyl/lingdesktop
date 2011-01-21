class User < Neo4j::Model
  devise :database_authenticatable, :trackable

  attr_accessible :email, :password, :password_confirmation, :name, :is_admin, :remember_me, :created_at, :last_sign_in_at
  
  property :name
  property :email
  property :password
  property :is_admin, :default => false
  
  index :email
  index :name
  
  has_one(:context).to(RDF_Context)
  
  after_create :add_context
  
  def to_hash
    {
      :email => self.email,
      :name => self.name,
      :id => self.id,
      :is_admin => self.is_admin,
      :created_at => self.created_at,
      :last_login_at => self.last_sign_in_at
    }
  end
  
  private
  
    def add_context
      uri = "http://purl.org/linguistics/lingdesktop/contexts/" +
            self.email.gsub(/\./, "_dot_").gsub(/@/, "_at_")    
      self.context = RDF_Context.find_or_create(:uri_esc => uri.uri_esc)
      self.save
    end
end