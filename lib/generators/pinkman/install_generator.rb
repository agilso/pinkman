require 'rails/generators/base'

module Pinkman
  class InstallGenerator < ::Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)
    
    def create_directories
      FileUtils.mkdir_p Rails.root.join('app','views','pinkman')
      FileUtils.mkdir_p Rails.root.join('app','assets','javascripts','pinkman','models')
    end

    def create_api_routes
      inject_into_file 'config/routes.rb', after: ".routes.draw do" do
        ["\n \n \t" 'namespace :api do',"\tend"].join("\n")
      end
    end

    def create_api_controller_file
      copy_file "api_controller.rb", Rails.root.join('app','controllers','api_controller.rb')
    end
  end
end