require 'rails/generators/base'

module Pinkman
  class ControllerGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    argument :controller_arg, type: :string

    def generate_files
      template "controller.coffee.erb", file_path
    end

    private
    
    def file_path
      path = controller_arg.split('/')
      Rails.root.join('app','assets','pinkman','app','controllers',*path.map{|p| p.tableize.strip })
    end
    
    def controller_name
      controller_arg.split('/').last.tableize.strip.gsub('_','-')
    end

  end
end