##
# Users Controller
#
# @example Do something
#   Gold Controller
#
class HelpController < ApplicationController

  def show
    respond_to do |format|
      format.html {render params[:id]}
    end
  end

end