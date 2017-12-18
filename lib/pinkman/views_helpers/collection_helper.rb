require_relative 'base_helper.rb'

module Pinkman
  module ViewsHelpers
    module CollectionHelper
      
      extend BaseHelper
      
      define_helper :each do |block=nil|
        p.wrap_in('collection',&block)
      end
      define_helper_alias :collection, :each
      
    end
  end
end