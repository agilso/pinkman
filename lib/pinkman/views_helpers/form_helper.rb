require_relative 'base_helper.rb'

module Pinkman
  module ViewsHelpers
    module FormHelper
      
      extend BaseHelper
      
      define_helper :input do |hash|
        hash[:type] ||= 'text'
        tag(:input,hash.merge(data: {pinkey: p.pinkey, action: hash[:name]}, value: p.write(hash[:name])))
      end
    
      define_helper :textarea do |hash|
        content_tag('textarea',hash.merge(data: {pinkey: p.pinkey, action: hash[:name]}, value: p._w(hash[:name]))) do 
          p._w(hash[:name])
        end
      end
      
    end
  end
end