require_relative '../base_helper.rb'
require_relative '../views_helpers/form_helper.rb'

module Pinkman
  module FormHelper
    module FormHelpers
      
      extend Pinkman::BaseHelper
      
      include Pinkman::ViewsHelpers::FormHelper
      
      define_helper :string do |attr_name,label=nil,html_attributes={}|
        p.input_helper attr_name, label, html_attributes.merge(type: 'text')
      end
      
      define_helper :text do |attr_name,label=nil,html_attributes={}|
        label ||= attr_name.titleize
        
        error_for_name = html_attributes.delete(:error_for) || attr_name
        error_prepend = html_attributes.delete(:error_prepend)
        error_for_name = error_prepend + error_for_name if error_prepend
        
        render partial: 'pinkman/pinkman/form_textarea', locals: {attr_name: attr_name, label: label, error_for_name: error_for_name, textarea_options: {name: attr_name}.merge(html_attributes) }
      end
      
      define_helper :date do |attr_name,label=nil,html_attributes={}|
        p.input_helper attr_name, label, html_attributes.merge(type: 'date')
      end
      
      define_helper :datetime do |attr_name,label=nil,html_attributes={}|
        p.input_helper attr_name, label, html_attributes.merge(type: 'time')
      end
      
      define_helper :color do |attr_name,label=nil,html_attributes={}|
        p.input_helper attr_name, label, html_attributes
      end
      
      define_helper :select do |attr_name,label,options_hash,html_attributes={}|
        if html_attributes.has_key?(:placeholder)
          placeholder = html_attributes[:placeholder]
          obligatory = html_attributes[:obligatory]
          html_attributes.delete(:placeholder)
        end
        obligatory = true if obligatory.nil?
        label ||= attr_name.titleize
        error_for_name = html_attributes.delete(:error_for) || attr_name
        error_prepend = html_attributes.delete(:error_prepend)
        error_for_name = error_prepend + error_for_name if error_prepend
        render partial: 'pinkman/pinkman/form_select', locals: {attr_name: attr_name, label: label, error_for_name: error_for_name, options_hash: options_hash, html_attributes: html_attributes, placeholder: placeholder, obligatory: obligatory}
      end
      
      define_helper :password do |attr_name,label=nil,html_attributes={}|
        p.input_helper attr_name, label, html_attributes.merge(type: 'password')
      end
      
      define_helper :number do |attr_name,label=nil,html_attributes={}|
        p.input_helper attr_name, label, html_attributes.merge(type: 'number')
      end
      
      define_helper :money do |attr_name,label=nil,html_attributes={}|
        p.input_helper attr_name, label, html_attributes.merge(type: 'number', step: '0.01')
      end
      
    end
  end
end