class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def context
    @context ||= init_context
  end
  
  def lingdesktop_context
    @lingdesktop_context ||= User.find(:email => "lingdesktop@lingdesktop.org").context
  end
  
  def init_context
    if params.has_key?(:context_id) && params[:context_id] == "lingdesktop"
      return lingdesktop_context
    elsif params.has_key?(:context_id) && params[:context_id] != "lingdesktop"
      return RDF_Context.find(params[:context_id])
    elsif user_signed_in?
      return current_user.context
    end
  end
  
  
  
end
