module ContextsHelper
  
  def link_to_resources(type, context_id)
    link = '<a href="" onclick=' +
    '"Desktop.AppMgr.display(\'resource_index\', \''+ 
    type.to_s.underscore.downcase.pluralize +
    '\', {contextId:' + context_id + '}); return false;" >' + 
    type.to_s.pluralize + 
    '</a>'
    
    link.html_safe
  end
  
end