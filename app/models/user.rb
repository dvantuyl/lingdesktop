class User < RDF_Context

  attr_accessible :email, :password, :password_confirmation, :uri_esc, :name, :is_admin, :remember_me, :created_at, :last_sign_in_at
  
  property :name
  property :email
  property :password
  property :is_admin, :default => false
  
  index :email
  index :name
  
  def to_hash
    {
      :email => self.email,
      :name => self.name,
      :uri => self.uri,
      :localname => self.localname,
      :is_admin => self.is_admin,
      :created_at => self.created_at,
      :last_login_at => self.last_sign_in_at
    }
  end
end