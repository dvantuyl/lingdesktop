class User < RDF_Context

  property :email, :name, :provider
  property :is_admin #, :type => Boolean

  index :provider
  validates_presence_of :provider

  
  def self.find_from_hash(hash)
    provider = User.escape_uri(hash['provider'])
    uri = User.escape_uri(hash['uid'])
    User.find("provider: #{provider} AND uri: #{uid}")
  end
  
  def self.create_from_hash(hash)
    provider = User.escape_uri(hash['provider'])
    uri = User.escape_uri(hash['uid'])
    
    user = User.create(:provider => provider, :uri => uri)
    user.email = hash['user_info']['email'] if hash['user_info'].has_key?('email')
    user.name = hash['user_info']['name'] if hash['user_info'].has_key?('name')
    user.is_admin = false
    
    return user.save
  end
  
  def to_hash
    return {
      :uri => URI.unescape(self.uri),
      :provider => URI.unescape(self.provider),
      :user_info => {
        :email => self.email,
        :name => self.name,
        :is_admin => self.is_admin
      }
    }
  end
end