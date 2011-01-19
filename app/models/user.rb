class User < RDF_Context
  devise :database_authenticatable, :registerable, :token_authenticatable, :rememberable, :trackable, :omniauthable
  
  attr_accessible :email, :password, :password_confirmation, :uri_esc
  
  property :name
  property :email
  property :password
  
  index :email
  index :name
end