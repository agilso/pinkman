require_relative '../base_helper.rb'

module Pinkman
  module ViewsHelpers
    module FormHelper
      
      extend Pinkman::BaseHelper
      
      define_helper :textfield do |attr_name,label=nil|
        label ||= attr_name.titleize
        render partial: 'pinkman/pinkman/form_input', locals: {attr_name: attr_name, label: label, input_options: {name: attr_name}}
      end
      
      define_helper :datefield do |attr_name,label=nil|
        label ||= attr_name.titleize
        render partial: 'pinkman/pinkman/form_input', locals: {attr_name: attr_name, label: label, input_options: {name: attr_name}}
      end
      
      define_helper :input do |hash|
        hash[:type] ||= 'text'
        tag(:input,hash.merge(data: {pinkey: p.pinkey, action: hash[:name]}, value: p.write(hash[:name])))
      end
    
      define_helper :textarea do |hash|
        content_tag('textarea',hash.merge(data: {pinkey: p.pinkey, action: hash[:name]}, value: p._w(hash[:name]))) do 
          p._w(hash[:name])
        end
      end
      
      define_helper :select do |attr_name,options_hash={}, block|
        content_tag('select',options_hash.merge({name: attr_name, data: {pinkey: p.pinkey, action: attr_name}}),&block)
      end
      
      define_helper :form do |action_name, hash={}, block|
        content_tag 'form',hash.merge({action: '', data: {pinkey: p.pinkey, action: action_name}}) do
          block.call(Pinkman::FormHelper.dispatcher(self))
        end
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