module Lingdesktop
  class ModelGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)
    check_class_collision
    
    def create_model_files
      template 'model.rb', File.join('app/models', class_path, "#{file_name}.rb")
    end
  end
end
