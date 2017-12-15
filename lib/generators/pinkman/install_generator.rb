require 'rails/generators/base'

module Pinkman
  class InstallGenerator < ::Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)
    
    def create_directories
      FileUtils.mkdir_p Rails.root.join('app','views','pinkman')
      FileUtils.mkdir_p Rails.root.join('app','assets','javascripts','pinkman','app','models')
      FileUtils.mkdir_p Rails.root.join('app','assets','javascripts','pinkman','app','controllers')
      FileUtils.mkdir_p Rails.root.join('app','assets','javascripts','pinkman','app','mixins')
      FileUtils.mkdir_p Rails.root.join('app','assets','javascripts','pinkman','base')
      FileUtils.mkdir_p Rails.root.join('app','assets','javascripts','pinkman','config')
      FileUtils.mkdir_p Rails.root.join('app','assets','javascripts','pinkman','test')
      FileUtils.mkdir_p Rails.root.join('app','serializers')
      FileUtils.mkdir_p Rails.root.join('app','controllers','api')
    end

    def create_api_routes
      inject_into_file 'config/routes.rb', after: ".routes.draw do" do
        ["\n \n \t" + 'namespace :api do',"\tend"].join("\n")
      end
    end
    
    def modify_application_js
      append_to_file Rails.root.join('app','assets','javascripts','application.js') do
        '//= require my.pinkman.app'
      end
    end
    
    def copy_my_pinkman_app_js_to_rails
      copy_file "my.pinkman.app.js", Rails.root.join('app','assets','javascripts','my.pinkman.app.js')
    end

    def create_api_controller_file
      copy_file "api_controller.rb", Rails.root.join('app','controllers','api_controller.rb')
    end

    def create_app_files
      generate 'pinkman:app_base'
    end
    
    def create_initializer
      generate 'pinkman:initializer'
    end
    
    def install_hello_world_controller
      copy_file "hello.controller.coffee.erb", Rails.root.join('app','assets','javascripts','pinkman','app','controllers','hello.coffee')
    end
    
    def install_mixin_example
      copy_file "example.mixin.coffee.erb", Rails.root.join('app','assets','javascripts','pinkman','app','mixins','example.mixin.coffee')
    end
    
  end
end