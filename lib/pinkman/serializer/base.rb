require 'active_model_serializers'
require_relative 'scope'

module Pinkman
  module Serializer
    class Base < ActiveModel::Serializer
      @@scopes = {}

      self.root = false

      def self.scope name=:all, &block
        if block_given?
          @@scopes[name.to_sym] ||= Pinkman::Serializer::Scope.new(serializer: self)
          yield(@@scopes[name.to_sym]) 
        else
          @@scopes[name.to_sym]
        end
      end

      def self.model
        @model || (begin eval(self.to_s.sub('Serializer','')) rescue nil end)
      end

      def self.model= value
        @model = value
      end

      def attributes *args
        hash = super(*args)
        if scope
          pinkmanscope = self.class.scope(scope)
          include_all = pinkmanscope.read.include?(:all)
          model = self.class.model
          model.column_names.each {|attribute| hash[attribute] = object.send(attribute) } if include_all && model && model.methods.include?(:column_names)
          pinkmanscope.read.each {|attribute| hash[attribute] = object.send(attribute) if object.methods.include?(attribute)}
          pinkmanscope.read.each {|attribute| hash[attribute] = send(attribute) if self.methods.include?(attribute)}
          hash
        end
      end
    end
  end
end