require 'rails/generators/base'

module Pinkman
  class AppBaseGenerator < ::Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)

    def generate_files
      template 'app_app.coffee.erb', "app/assets/javascripts/pinkman/base/#{app_filename}"
      template 'app_router.coffee.erb', "app/assets/javascripts/pinkman/base/#{router_filename}"
      template 'app_collection.coffee.erb', "app/assets/javascripts/pinkman/base/#{collection_filename}"
      template 'app_object.coffee.erb', "app/assets/javascripts/pinkman/base/#{object_filename}"
      template 'app_routes.coffee.erb', "app/assets/javascripts/pinkman/config/routes.coffee"
    end
    
    private


    def app_filename
      'app.coffee'
    end
    
    def router_filename
      'router.coffee'
    end
    
    def object_filename
      'object.coffee'
    end

    def collection_filename
      'collection.coffee'
    end

    def app_name
      'App'
    end

    def app_object_name
      app_name + 'Object'
    end

    def app_collection_name
      app_name + 'Collection'
    end
  
  end

end