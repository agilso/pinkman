require 'rails'
require 'pathname'
require 'active_model_serializers'
require 'pinkman/serializer'
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

      # Active Record Relation: json_for
      ActiveRecord::Relation.class_eval do 
        def json_for scope_name
          a = ActiveModel::ArraySerializer.new(self, each_serializer: model.serializer, scope: scope_name)
          a.to_json
        end
      end

      # Instance method: json_for
      ActiveRecord::Base.class_eval do
        def json_for scope_name
          s = self.class.serializer.new(self,scope: scope_name)
          s.to_json
        end
      end
    end
  end
  
end
