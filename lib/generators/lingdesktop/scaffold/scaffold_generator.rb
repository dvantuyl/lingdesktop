module Lingdesktop
  class ScaffoldGenerator < Rails::Generators::NamedBase
    
    def generate_mvc
      generate("lingdesktop:controller", singular_name)
      generate("lingdesktop:model", singular_name)
      generate("lingdesktop:desktop_app", singular_name)
    end
  end
end