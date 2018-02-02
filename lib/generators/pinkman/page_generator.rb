require 'rails/generators/base'

module Pinkman
  class PageGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    
    argument :page_name, type: :string, default: "nameHere"

    def exec
      generate "pinkman:route #{page_name}"
      generate "pinkman:controller #{page_name}"
      generate "pinkman:template #{page_name}"
    end
  end
end