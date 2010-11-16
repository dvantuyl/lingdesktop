# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

def rm_db_storage
  FileUtils.rm_rf Neo4j::Config[:storage_path]
  raise "Can't delete db" if File.exist?(Neo4j::Config[:storage_path])
end

def finish_tx
  return unless @tx
  @tx.success
  @tx.finish
  @tx = nil
end

def new_tx
  finish_tx if @tx
  @tx = Neo4j::Transaction.new
end

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  
  config.before(:each, :type => :transactional) do
    new_tx
  end

  config.after(:each, :type => :transactional) do
    finish_tx
    Neo4j::Transaction.run do
      Neo4j._all_nodes.each { |n| n.del unless n.neo_id == 0 }
    end
  end

  config.after(:each) do
    finish_tx
    Neo4j::Transaction.run do
      Neo4j._all_nodes.each { |n| n.del unless n.neo_id == 0 }
    end
  end

  config.before(:all) do
    Neo4j.start
  end

  config.after(:all) do
    finish_tx
    Neo4j.shutdown
    rm_db_storage
  end


end
