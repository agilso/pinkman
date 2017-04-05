require 'rails/generators/base'

module Pinkman
  class ApiGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    argument :class_name, type: :string, default: "nameHere"

    def generate_api_file
      template "api.rb.erb", "app/controllers/api/#{controller_file_name}"
    end

    def insert_a_resource_in_routes      
      inject_into_file 'config/routes.rb', after: "namespace :api do" do
        %/
    resources :#{api_name} do
      collection do 
        get 'search(\/:query)', action: 'search'
      end
    end 
    /
      end
    end

    private

    def api_name
      class_name.pluralize.underscore
    end

    def collection_name
      api_name
    end

    def instance_name
      class_name.underscore
    end

    def controller_name
      api_name.camelize + "Controller"
    end

    def serializer_name
      active_record_model_name + "Serializer"
    end

    def controller_file_name
      api_name.underscore + "_controller.rb"
    end

    def params_method_name
      instance_name + "_params"
    end

    def active_record_model_name
      class_name.camelize
    end

  end
end