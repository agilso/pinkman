require 'pathname'
require 'rails'
require 'pinkman/version'

module Pinkman
  class Engine < ::Rails::Engine
  end
  def self.root
    Pathname.new(File.dirname(__FILE__)).join('..')
  end 
end
