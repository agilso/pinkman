require 'rails'
require 'pathname'
require 'active_model_serializers'
require 'pinkman/serializer'
require 'pinkman/views_helpers'
require 'pinkman/form_helper'
require 'pinkman/version'
require 'pinkman/broadcaster'

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
      
      # Extending ActiveRecord
      ActiveRecord::Base.singleton_class.class_eval do 
        
        # Serializer
        def serializer= value
          @serializer = value
        end

        def serializer
          @serializer || (begin eval(self.to_s + 'Serializer') rescue nil end)
        end
        
        # Get: Pinkman way of fetching records
        def get query
          if (begin Integer(query) rescue false end)
            [find(query)]
          elsif query.is_a? Hash
            where(query)
          elsif query.is_a? Array
            where(id: query)
          elsif query.is_a? String
            search(query)
          else
            []
          end
        end
        
      end

      # Active Record Relation: json
      ActiveRecord::Relation.class_eval do 
        def json scope_name, params_hash = {}
          serialize_for(scope_name, params_hash).to_json
        end
        
        def json_for *args, &block
          ActiveSupport::Deprecation.warn('"json_for" deprecated. Use "json" instead.')
          json(*args, &block)
        end
        
        def serialize_for scope_name, params_hash = {}
          options = {scope: scope_name}.merge(params: params_hash)
          s = Pinkman::Serializer::array(self, options)
          s
        end
      end

      Array.class_eval do
        def json scope_name, params_hash = {}
          serialize_for(scope_name, params_hash).to_json
        end
        
        def json_for *args, &block
          ActiveSupport::Deprecation.warn('"json_for" deprecated. Use "json" instead.')
          json(*args, &block)
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
          json(*args, &block)
        end
        
        def has_json_key? key, scope
          json_version = JSON.parse(json(scope))
          json_version.has_key?(key.to_s) and json_version[key.to_s].present?
        end
        
        def json_hash scope
          JSON.parse(json(scope))
        end

      end
    end
    
  end
  
end
