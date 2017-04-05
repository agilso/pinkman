require 'rails/generators/base'

module Pinkman
  class ModelGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    argument :class_name, type: :string, default: "nameHere"

    def generate_files
      template "object.js.erb", "app/assets/javascripts/pinkman/models/#{directory_name}/#{object_file_name}"
      template "collection.js.erb", "app/assets/javascripts/pinkman/models/#{directory_name}/#{collection_file_name}"
    end

    private

    def directory_name
      class_name.pluralize.underscore
    end

    def object_class_name
      class_name.camelize
    end

    def object_file_name
      class_name.underscore + ".js.coffee"
    end

    def collection_class_name
      class_name.pluralize.camelize
    end

    def collection_file_name
      class_name.pluralize.underscore + ".js.coffee"
    end 

    def guess_api_url
      "api/#{class_name.pluralize.underscore}"
    end

  end
end