require 'rails/generators/base'

module Pinkman
  class ModelGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    argument :class_name, type: :string, default: "nameHere"

    def generate_files
      template "object.coffee.erb", "app/assets/javascripts/pinkman/app/models/#{directory_name}/#{object_file_name}"
      template "collection.coffee.erb", "app/assets/javascripts/pinkman/app/models/#{directory_name}/#{collection_file_name}"
    end

    private

    def directory_name
      class_name.pluralize.underscore
    end

    def object_class_name
      class_name.camelize
    end

    def object_file_name
      class_name.underscore + ".coffee"
    end

    def collection_class_name
      class_name.pluralize.camelize
    end

    def collection_file_name
      class_name.pluralize.underscore + ".coffee"
    end 

    def guess_api_url
      "api/#{class_name.pluralize.underscore}"
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