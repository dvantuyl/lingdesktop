class User < RDF_Context

  property :email, :name, :provider_uri_esc
  property :is_admin #, :type => Boolean

  index :provider_uri_esc
  index :email
  
  validates_presence_of :provider_uri_esc
  validates :email, :presence => true, :uniqueness => true

  
  def provider_uri
    self[:provider_uri_esc].uri_unesc
  end
  
  def self.find_from_hash(hash)
    provider_uri_esc = hash['provider'].uri_esc
    uri_esc = hash['uid'].uri_esc
    User.find("provider_uri_esc: #{provider_uri_esc} AND uri_esc: #{uri_esc}")
  end
  
  def self.create_from_hash(hash)
    provider_uri_esc = hash['provider'].uri_esc
    uri_esc = hash['uid'].uri_esc
    
    user = User.create(:provider_uri_esc => provider_uri_esc, :uri_esc => uri_esc)
    user.email = hash['user_info']['email'] if hash['user_info'].has_key?('email')
    user.name = hash['user_info']['name'] if hash['user_info'].has_key?('name')
    user.is_admin = false
    user.save
    
    return user
  end
  
  def to_hash
    return {
      :uri => self.uri,
      :provider => self.provider_uri,
      :user_info => {
        :email => self.email,
        :name => self.name,
        :is_admin => self.is_admin
      }
    }
  end
end