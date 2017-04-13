require 'ostruct'
require 'pathname'
require 'rails'
require 'pinkman/version'

module Pinkman

  @@configuration = OpenStruct.new js_template_engine: 'handlebars'

  def self.root
    Pathname.new(File.dirname(__FILE__)).join('..')
  end 

  def self.configuration
    @@configuration
  end

  def self.setup
    yield @@configuration
  end
  
  class Engine < ::Rails::Engine
    config.after_initialize do
      if Slim
        Slim::Engine.set_options attr_list_delims: {'(' => ')', '[' => ']'}
      end
    end
  end
  
end
