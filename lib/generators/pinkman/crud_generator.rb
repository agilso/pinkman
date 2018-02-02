require 'rails/generators/base'

module Pinkman
  class CrudGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    
    argument :crud_name, type: :string, default: "nameHere"

    def exec
      generate "pinkman:route_resource #{crud_name}"
      generate "pinkman:controller #{crud_name}:index"
      generate "pinkman:template #{crud_name}:index"
      
      generate "pinkman:controller #{crud_name}:show"
      generate "pinkman:template #{crud_name}:show"
      
      generate "pinkman:controller #{crud_name}:new"
      generate "pinkman:template #{crud_name}:new"
      
      generate "pinkman:controller #{crud_name}:edit"
      generate "pinkman:template #{crud_name}:edit"
    end
  end
end