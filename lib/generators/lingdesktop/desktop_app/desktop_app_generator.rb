module Lingdesktop
  class DesktopAppGenerator < Rails::Generators::NamedBase
    include Rails::Generators::ResourceHelpers
   
    source_root File.expand_path('../templates', __FILE__)

    def create_desktop_app_files
      template 'index.js', File.join("public/javascripts/Apps/#{controller_file_name.capitalize}", class_path, 'index.js')
      template 'edit.js', File.join("public/javascripts/Apps/#{controller_file_name.capitalize}", class_path, 'edit.js')
      template 'help.js', File.join("public/javascripts/Apps/#{controller_file_name.capitalize}", class_path, 'help.js')
      template 'view.js', File.join("public/javascripts/Apps/#{controller_file_name.capitalize}", class_path, 'view.js')
    end
    
    def create_view_files       
      template 'show.html.erb', File.join("app/views/#{controller_file_name}", class_path, "show.html.erb")     
      template 'help.html.erb', File.join("app/views/help", class_path, "#{controller_file_name}.html.erb")    
    end
    
  end
end
