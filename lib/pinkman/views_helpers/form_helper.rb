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
      
      define_helper :form do |action_name,block|
        content_tag('form',{action: '', data: {pinkey: p.pinkey, action: action_name}},&block)
      end
      
      define_helper :submit do |val|
        tag 'input', {type: 'submit', value: val, class: 'submit-button'}
      end
      
      define_helper :error_for do |attr,label=nil|
        label ||= attr.to_s.titleize
        render partial: '/pinkman/error_for', locals: {attribute: attr, label: label}
      end
      
      define_helper :has_errors? do |block|
        p.if('errors',block)
      end
      
      define_helper :valid? do |block|
        p.unless('errors',block)
      end
      
      define_helper :first_error do
        p._w('firstError')
      end
      
    end
  end
end