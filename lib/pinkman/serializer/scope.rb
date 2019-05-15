module Pinkman
  module Serializer
    class Scope
      
      attr_accessor :name, :read, :write, :access, :serializer

      def initialize hash
       if hash.is_a?(Hash)
         self.serializer = hash[:serializer]
         self.name = hash[:name]
       end
       self
     end
      
      def read_ghost
        @read_ghost || []
      end
      
      def read_ghost= value
        @read_ghost = value
      end

      def read_attributes *args
        self.read = args
        self.read = [] unless args.first
        query_optimizer
        read
      end
      
      def associations
        read.select{ |attribute| attribute_is_association?(attribute) }
      end
      
      def fields
        read.select{ |attribute| attribute_is_in_db?(attribute) }
      end
      
      def query_optimizer 
        select_optimizer
        include_optimizer
      end
      
      def select_optimizer
        unless :all.in?(read.map(&:to_sym))
          fields.each do |attribute|
            selecting << "#{serializer.table_name}.#{attribute}"
          end
        end
        selecting
      end
      
      def include_optimizer
        associations.each do |attribute|
          including << attribute_inclusion_clause(attribute)
        end
        including
      end
      
      def selecting
        @selecting ||= []
      end
      
      def including
        @including ||= []
      end
      
      def read_ghost_attributes *args
        self.read_ghost = args
        self.read_ghost = [] unless args.first
        read_ghost
      end

      def write_attributes *args
        self.write = args
        self.write = [] unless args.first
        write
      end

      def access_actions *args
        self.access = args
        self.access = [] unless args.first
        access
      end
      
      def associations_inclusion
        @associations_inclusion ||= []
      end
      
      def associations_inclusion= val
        @associations_inclusion = val
      end
      
      def include_associations *args
        self.associations_inclusion = args
      end

      def can_read? attribute
        read.include?(:all) or read.include?(attribute.to_sym) or attribute.to_sym == :error or attribute.to_sym == :errors or read_ghost.include?(attribute.to_sym)
      end

      def can_write? attribute
        (write.include?(:all) or write.include?(attribute.to_sym)) and (serializer.model.column_names.include?(attribute.to_s) or (serializer.model.instance_methods.include?("#{attribute.to_s}=".to_sym) and write.include?(attribute.to_sym)))
      end

      def can_access? action
        access.include?(:all) or access.include?(action.to_sym)
      end

      def can_read
        read + read_ghost
      end

      def can_write
        write
      end

      def can_access
        access
      end
      
      # private
      
      def reflections
        serializer.reflections
      end
      
      def attribute_is_in_db?(attribute)
        attribute.to_s.in?(serializer.model.column_names)
      end
      
      def attribute_is_association?(attribute)
        attribute.to_s.in?(reflections.keys.map(&:to_s))
      end
      
      def attribute_inclusion_clause attribute
        if attribute_has_nested_associated?(attribute)
          a = []
          assoc_scope = attribute_assoc_scope(attribute)
          assoc_scope.associations.each do |assoc_attribute|
            a << assoc_scope.attribute_inclusion_clause(assoc_attribute)
          end
          { attribute.to_sym => a }
        else
          attribute.to_sym
        end
      end
      
      
      
      def get_associated_model(reflection)
        if reflection.options[:polymorphic]
          reflection.klass
        else
          reflection.active_record
        end
      end
      
      def get_associated_serializer(attribute)
        begin
          get_associated_model(reflections[attribute.to_s]).serializer if attribute_is_association?(attribute.to_s)
        rescue
          raise ArgumentError, "#{serializer}.#{name}: association named - #{attribute} - found but I can't find its serializer."
        end
      end
      
      def attribute_assoc_scope(attribute)
        assoc_serializer = get_associated_serializer(attribute)
        if assoc_serializer
          assoc_serializer.scope(name.to_sym) 
        else
          binding.pry
          raise ArgumentError, "#{serializer}.#{name}: association named - #{attribute} - found but I can't find its serializer."
        end
      end
    
      # given that a attribute is a association,
      # and the associated serializer has same scope defined,
      # checks if a nested association is present
      def attribute_has_nested_associated?(attribute)
        attribute = attribute.to_s
        if attribute_is_association?(attribute)
          assoc_scope = attribute_assoc_scope(attribute)
          assoc_scope && assoc_scope.associations.any? && assoc_scope.serializer.model != serializer.model
        end
      end
      
    end
  
  end
end