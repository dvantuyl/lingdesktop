require 'openid/store/filesystem'

Rails.application.config.middleware.use OmniAuth::Builder do
  #provider :facebook, 'APP_ID', 'APP_SECRET'
  provider :open_id, OpenID::Store::Filesystem.new('/tmp')
  provider :open_id, OpenID::Store::Filesystem.new('/tmp'), :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id'
  provider :open_id, OpenID::Store::Filesystem.new('/tmp'), :name => 'yahoo', :identifier => 'http://yahoo.com'
end