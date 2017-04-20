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
      app_name.underscore.downcase + '_object.coffee'
    end

    def collection_filename
      app_name.underscore.downcase + '_collection.coffee'
    end

    def app_name
      Rails.application.class.parent_name
    end

    def app_object_name
      app_name.camelize + 'Object'
    end

    def app_collection_name
      app_name.camelize + 'Collection'
    end
  
  end

end