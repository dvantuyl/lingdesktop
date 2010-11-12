class SessionsController < ApplicationController
  def create
    auth = request.env['rack.auth']
    user = User.find_from_hash(auth)
    self.current_user = (user || User.create_from_hash(auth))

    redirect_to "/"
  end
end