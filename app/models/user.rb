class User < RDF_Context

  property :email, :name, :provider_uri_esc
  property :is_admin #, :type => Boolean

  index :provider_uri_esc
  validates_presence_of :provider_uri_esc

  
  def provider
    self[:provider].uri_unesc
  end
  
  def self.find_from_hash(hash)
    provider = hash['provider'].uri_esc
    uri = hash['uid'].uri_esc
    User.find("provider_uri_esc: #{provider} AND uri_esc: #{uri}")
  end
  
  def self.create_from_hash(hash)
    provider = hash['provider'].uri_esc
    uri = hash['uid'].uri_esc
    
    user = User.create(:provider_uri_esc => provider, :uri_esc => uri)
    user.email = hash['user_info']['email'] if hash['user_info'].has_key?('email')
    user.name = hash['user_info']['name'] if hash['user_info'].has_key?('name')
    user.is_admin = false
    
    return user.save
  end
  
  def to_hash
    return {
      :uri => self.uri,
      :provider => self.provider,
      :user_info => {
        :email => self.email,
        :name => self.name,
        :is_admin => self.is_admin
      }
    }
  end
end