require 'rails/generators/base'

module Pinkman
  class ResourceGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    
    argument :class_name, type: :string, default: "nameHere"

    def exec
      generate "pinkman:api #{class_name}"
      generate "pinkman:model #{class_name}"
      generate "pinkman:serializer #{class_name}"
    end
  end
end