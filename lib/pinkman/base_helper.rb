module Pinkman
  module BaseHelper
  
    def define_helper m, &block
      define_method m do
        Proc.new(&block)
      end
    end
    
    def define_helper_alias n, o 
      send :alias_method, n, o
    end
  end

end  