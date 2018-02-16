require 'rails/generators/base'

module Pinkman
  class ControllerGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    argument :controller_arg, type: :string
    
    def normalize_argument
      self.controller_arg = controller_arg.downcase.gsub(' ','_').strip.squeeze('_').gsub(/:/,'/')
    end

    def generate_controller
      template "controller.coffee.erb", file_path
    end

    private
    
    def file_path
      path = (controller_arg + '.coffee').split('/')
      Rails.root.join('app','assets','javascripts','pinkman','app','controllers',*path.map{|p| p})
    end
    
    def controller_name
      controller_arg.split('/').join('-').gsub(/[_\/]/,'-')
    end

  end
end