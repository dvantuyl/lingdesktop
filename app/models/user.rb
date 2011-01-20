class User < RDF_Context
  devise :database_authenticatable, :token_authenticatable, :rememberable, :trackable, :omniauthable
  
  attr_accessible :email, :password, :password_confirmation, :uri_esc, :name, :role, :remember_me, :created_at, :last_sign_in_at
  
  property :name
  property :email
  property :password
  property :role
  
  index :email
  index :name
  
  ROLES = %w[admin user]
  
  def to_hash
    {
      :email => self.email,
      :name => self.name,
      :uri => self.uri,
      :role => self.role,
      :created_at => self.created_at,
      :last_login_at => self.last_sign_in_at
    }
  end
end