module ApplicationHelper
  def link_to_dtapp(display, app_id, instance_id, context_id = '0')
    link = '<a href="" onclick=' +
    '"Desktop.AppMgr.display(\'' + app_id + '\', \''+ 
    instance_id +
    '\', {title: \'' + display +'\', contextId: ' + context_id + '}); return false;" >' + 
    display + 
    '</a>'
    
    link.html_safe
  end
end
