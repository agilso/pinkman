require 'rails/generators/base'

module Pinkman
  class InitializerGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def copy_initializer_file
      template "initializer.rb.erb", "config/initializers/pinkman.rb"
    end

  end
end