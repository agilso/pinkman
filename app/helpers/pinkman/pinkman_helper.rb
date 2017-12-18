require 'pinkman/views_helpers'

module Pinkman
  module PinkmanHelper   
      
    def p
      Pinkman::ViewsHelpers.dispatcher(self)
    end
    
    alias pink p
    alias pinkman p
    
  end
end