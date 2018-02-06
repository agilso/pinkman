require 'pinkman/views_helpers'

module Pinkman
  module PinkmanHelper   
      
    def p
      Pinkman::ViewsHelpers.dispatcher(self)
    end
    
    alias pink p
    alias pinkman p
    
    def f
      Pinkman::FormHelper.dispatcher(self)
    end
    
    alias pink_form f
    
  end
end