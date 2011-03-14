module Lingdesktop
  class ControllerGenerator < Rails::Generators::NamedBase
    include Rails::Generators::ResourceHelpers
    
    source_root File.expand_path('../templates', __FILE__)
    check_class_collision :suffix => "Controller"
    
    def create_controller_files
      template 'controller.rb', File.join('app/controllers', class_path, "#{controller_file_name}_controller.rb")
    end
  end
end
