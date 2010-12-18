require "spec_helper"

describe User do
  before(:each) do
    @context_one = User.create(
      :uri_esc => "http://context.one".uri_esc,
      :provider_uri_esc => "http://google.com".uri_esc,
      :email => "context@test.one"
    )
    @context_two = User.create(
      :uri_esc => "http://context.two".uri_esc,
      :provider_uri_esc => "http://google.com".uri_esc,
      :email => "context@test.two"
    )
  end
  
  it_should_behave_like "All Contexts"
end