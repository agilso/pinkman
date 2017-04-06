require "pinkman/version"
require 'pathname'
require 'rails'

module Pinkman
  class Engine < ::Rails::Engine
  end
  def self.root
    Pathname.new(File.dirname(__FILE__)).join('..')
  end 
end
