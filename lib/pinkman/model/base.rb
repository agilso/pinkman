require 'active_record'

module Pinkman
  module Model
    class Base < ::ActiveRecord::Base
      
      self.abstract_class = true
      
      # Serializer
      def self.serializer= value
        @serializer = value
      end

      def self.serializer
        @serializer || (begin eval(self.to_s + 'Serializer') rescue nil end)
      end
      
      # Get: Pinkman way of fetching records
      def self.get query
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
      
      def self.optimize(scope, options = {})
        if  (options.keys - [:includes, :select]).any?
          raise ArgumentError, "#{self}.optimize called with invalid options. Options hash accepts :includes and :select only."
        end
        options_includes = options[:includes] || []
        options_select = options[:select] || []
        
        scope_obj = serializer.scope(scope)
        including_array = scope_obj.including + scope_obj.associations_inclusion + options_includes
        selecting_array = scope_obj.selecting + options_select
        
        includes(including_array).select(selecting_array)
      end
      def self.optim(*args)
        optimize(*args)
      end
      
      def serialize_for scope_name, params_hash = {}
        options = {scope: scope_name}.merge(params: params_hash)
        self.class.serializer.new(self,options)
      end

      def json scope_name=:public, params_hash={}
        serialize_for(scope_name, params_hash).to_json
      end
      
      def json_for *args, &block
        ActiveSupport::Deprecation.warn('"json_for" deprecated. Use "json" instead.')
        json(*args, &block)
      end
      
      def has_json_key? key, scope=:public, options={}
        json_version(scope, options).has_key?(key.to_s) and json_version(scope, options)[key.to_s].present?
      end
      
      def json_version *args
        JSON.parse(json(*args))
      end
      alias json_hash json_version
      
      def json_key key, scope=:public, options={}
        json_version(scope, options)[key.to_s]
      end
      
      
    end
  end
end