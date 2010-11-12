class User < CTX_Context

  property :email, :name, :provider
  property :is_admin #, :type => Boolean

  index :provider
  
  def self.find_from_hash(hash)
    User.find("provider = '#{hash['provider']}' AND uri = '#{hash['uid']}'").first
  end
  
  def self.create_from_hash(hash)
    user = User.new(:provider => hash['provider'], :uri => hash['uid'])
    user.email = hash['user_info']['email'] if hash['user_info'].has_key?('email')
    user.name = hash['user_info']['name'] if hash['user_info'].has_key?('name')
    user.is_admin = false
    return user
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