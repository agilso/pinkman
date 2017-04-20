require 'rails/generators/base'

module Pinkman
  class SerializerGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    argument :class_name, type: :string, default: "nameHere"

    def generate_file
      template "serializer.rb.erb", "app/serializers/#{serializer_file_name}"
    end

    private

    def api_name
      class_name.pluralize.underscore
    end

    def serializer_name
      active_record_model_name + "Serializer"
    end

    def serializer_file_name
      active_record_model_name.underscore + "_serializer.rb"
    end


    def active_record_model_name
      class_name.camelize
    end

  end
end