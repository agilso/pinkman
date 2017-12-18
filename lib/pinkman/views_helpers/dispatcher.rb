module Pinkman
  module ViewsHelpers
    class Dispatcher
      attr_accessor :rails_helper
      
      def initialize value
        @rails_helper = value
      end
      
      def method_missing m, *args, &block
        if Pinkman::ViewsHelpers.respond_to?(m)
          if block_given?
            rails_helper.instance_exec(*args,block,&Pinkman::ViewsHelpers.send(m))
          else
            rails_helper.instance_exec(*args,&Pinkman::ViewsHelpers.send(m))
          end
        else
          super(m)
        end
      end
    end
    
    def self.dispatcher rails_helper
      Dispatcher.new(rails_helper)
    end
  end
end