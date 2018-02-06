require_relative 'base_helper.rb'
require_relative 'form_helper/form_helpers.rb'

module Pinkman
  module FormHelper
    class Dispatcher
      attr_accessor :rails_helper
      
      def initialize value
        @rails_helper = value
      end
      
      def method_missing m, *args, &block
        if Pinkman::FormHelper.respond_to?(m)
          if block_given?
            rails_helper.instance_exec(*args,block,&Pinkman::FormHelper.send(m))
          else
            rails_helper.instance_exec(*args,&Pinkman::FormHelper.send(m))
          end
        else
          super(m)
        end
      end
    end
    
    def self.dispatcher rails_helper
      Dispatcher.new(rails_helper)
    end
  
    extend Pinkman::FormHelper::FormHelpers
    
  end
end
    
# --- About:
# This file defines the Pinkman form helpers we use in views. See views helper to understand how this works.