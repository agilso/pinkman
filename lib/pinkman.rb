require 'rails'
require 'pathname'
require 'active_model_serializers'
require 'pinkman/serializer'
require 'pinkman/views_helpers'
require 'pinkman/form_helper'
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
      Rails.application.routes.append do
        mount Pinkman::Engine => '/'
      end
      
      module ApplicationHelper
        extend PinkmanHelper
      end
      
      if defined? Slim
        Slim::Engine.set_options attr_list_delims: {'(' => ')', '[' => ']'}
      end
      
      # Class method: serializer
      ActiveRecord::Base.singleton_class.class_eval do 
        def serializer= value
          @serializer = value
        end

        def serializer
          @serializer || (begin eval(self.to_s + 'Serializer') rescue nil end)
        end
      end

      # Active Record Relation: json
      ActiveRecord::Relation.class_eval do 
        def json scope_name, params_hash = {}
          serialize_for(scope_name,params_hash).to_json
        end
        
        def json_for *args, &block
          ActiveSupport::Deprecation.warn('"json_for" deprecated. Use "json" instead.')
          json(*args,&block)
        end
        
        def serialize_for scope_name, params_hash = {}
          options = {scope: scope_name}.merge(params: params_hash)
          s = Pinkman::Serializer::array(self, options)
          s
        end
      end

      Array.class_eval do
        def json scope_name, params_hash = {}
          serialize_for(scope_name,params_hash).to_json
        end
        
        def json_for *args, &block
          ActiveSupport::Deprecation.warn('"json_for" deprecated. Use "json" instead.')
          json(*args,&block)
        end
        
        def serialize_for scope_name, params_hash = {}
          options = {scope: scope_name}.merge(params: params_hash)
          s = Pinkman::Serializer::array(self, options)
          s
        end
      end

      # Instance method: json
      ActiveRecord::Base.class_eval do
        def serialize_for scope_name, params_hash = {}
          options = {scope: scope_name}.merge(params: params_hash)
          self.class.serializer.new(self,options)
        end

        def json scope_name, params_hash={}
          serialize_for(scope_name,params_hash).to_json
        end
        
        def json_for *args, &block
          ActiveSupport::Deprecation.warn('"json_for" deprecated. Use "json" instead.')
          json(*args,&block)
        end

      end
    end
    
  end
  
end
