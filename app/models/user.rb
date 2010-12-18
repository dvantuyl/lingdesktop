class User < RDF_Context
  devise :database_authenticatable, :confirmable, :lockable, :recoverable,
          :rememberable, :registerable, :trackable, :timeoutable, :validatable,
          :token_authentatable


  attr_accessible :email, :password, :password_confirmation
  
  property :name
  property :email
  property :password

  index :email
  index :name

  
  def to_hash
    return {
      :uri => self.uri,
      :email => self.email,
      :name => self.name,
      :created_at => self.created_at
    }
  end
end