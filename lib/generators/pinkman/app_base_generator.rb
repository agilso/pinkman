require 'rails/generators/base'

module Pinkman
  class AppBaseGenerator < ::Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)

    def generate_files
      template 'app_collection.coffee.erb', "app/assets/javascripts/pinkman/#{collection_filename}"
      template 'app_object.coffee.erb', "app/assets/javascripts/pinkman/#{object_filename}"
    end
    
    private

    def object_filename
      'app_object.coffee'
    end

    def collection_filename
      'app_collection.coffee'
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