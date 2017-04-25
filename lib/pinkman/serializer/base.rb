require 'active_model_serializers'
require 'ostruct'
require_relative 'scope'

module Pinkman
  module Serializer

    class Base < ActiveModel::Serializer

      def initialize *args
        super(*args)
        @params = OpenStruct.new(args[1][:params]) if args.length > 1 and args[1].is_a?(Hash) and args[1][:params]
        self
      end

      attr_accessor :params

      self.root = false

      def self.scope name=:all, &block
        @scopes ||= {}
        if block_given?
          @scopes[name.to_sym] = Pinkman::Serializer::Scope.new(serializer: self)
          yield(@scopes[name.to_sym]) 
        else
          @scopes[name.to_sym]
        end
      end

      def self.scopes
        @scopes
      end

      def self.model
        @model || (begin eval(self.to_s.sub('Serializer','')) rescue nil end)
      end

      def self.model= value
        @model = value
      end

      def self.has_many *args
        args.each do |attribute|
          self.class_eval do |c|
            define_method attribute do
              reflection = object.class.reflections[attribute.to_s] 
              if reflection
                Pinkman::Serializer::array(object.send(attribute), scope: @scope)
              end
            end
          end
        end
      end

      def self.has_one *args
        args.each do |attribute|
          self.class_eval do |c|
            define_method attribute do
              reflection = object.class.reflections[attribute.to_s] 
              if reflection
                reflection.klass.serializer.new(object.send(attribute), scope: @scope)
              end
            end
          end
        end
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