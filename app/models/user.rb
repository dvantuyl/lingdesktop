class User < Neo4j::Model
  devise :database_authenticatable, :trackable

  attr_accessible :email, :password, :password_confirmation, :is_admin, :remember_me, :created_at, :last_sign_in_at,
    :is_public, :name, :description
  
  property :email
  property :password
  property :is_admin, :default => false
  property :is_public, :default => true
  property :name
  property :description
  
  index :email
  
  has_one(:context).to(RDF_Context)
  has_n(:groups).to(Group)
  
  before_create :add_context
  after_save :update_context
  
  def to_hash
    {
      :email => self.email,
      :name => self.name,
      :id => self.id,
      :is_admin => self.is_admin,
      :created_at => self.created_at,
      :last_login_at => self.last_sign_in_at,
      :context_id => self.context.id,
      :is_public => self.is_public,
      :description => self.description
    }
  end
  
  private
  
    def add_context
      self.context = RDF_Context.create(
        :name => self.name,
        :is_public => self.is_public,
        :description => self.description
      )
    end
    
    def update_context
      self.context.update_attributes(
        :is_public => self.is_public,
        :name => self.name,
        :description => self.description
      )
    end
end