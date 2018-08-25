module Pinkman
  module Serializer
    class Scope

      def initialize hash
       self.serializer = hash[:serializer] if hash.is_a?(Hash) and hash[:serializer]
      end

      attr_accessor :read, :write, :access, :serializer
      
      def read_ghost
        @read_ghost || []
      end
      
      def read_ghost= value
        @read_ghost = value
      end

      def read_attributes *args
        self.read = args
        self.read = [] unless args.first
        read
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
    end
  end
end