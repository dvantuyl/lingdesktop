module Lingdesktop
  class ScaffoldGenerator < Rails::Generators::NamedBase

    def add_resource_route
      route_config = "resources :#{plural_name} do "
      route_config << "post 'clone', :on => :member "
      route_config << " end"
      
      route route_config
    end
    
    def generate_mvc
      generate("lingdesktop:controller", singular_name)
      generate("lingdesktop:model", singular_name)
      generate("lingdesktop:desktop_app", singular_name)
    end
  end
end