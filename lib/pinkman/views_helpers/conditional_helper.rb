require_relative 'base_helper.rb'

module Pinkman
  module ViewsHelpers
    module ConditionalHelper
      
      extend BaseHelper
      
      define_helper :if do |condition, block=nil|
        p.wrap_in(condition,&block) if block.is_a?(Proc)
      end

      define_helper :unless do |condition, block=nil|
        raw "\n{{^ #{condition} }}\n \t #{capture(&block)} \n{{/ #{condition} }}\n" if block.is_a?(Proc)
      end
    
    end
  end
end