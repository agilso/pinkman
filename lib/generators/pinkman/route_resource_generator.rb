require 'rails/generators/base'

module Pinkman
  class RouteResourceGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    argument :route_arg, type: :string
    
    def normalize_argument
      self.route_arg = route_arg.downcase.gsub(' ','_').strip.squeeze('_').gsub(/:/,'/')
    end

    def generate_route
      # binding.pry
      if File.file?(file_path)
        inject_into_file file_path, after: ".define (routes) ->" do
          %/
  
  routes.resources '#{route_path}'/
        end
      end
    end
    
    private
    
    def route_path
      '/' + route_arg.sub('/index','')
    end
    
    def controller_name
      route_arg.split('/').join('-')
    end
    
    def file_path
      Rails.root.join('app','assets','javascripts','pinkman','config','routes.coffee')
    end

  end
end

