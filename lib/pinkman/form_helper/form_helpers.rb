require_relative '../base_helper.rb'
require_relative '../views_helpers/form_helper.rb'

module Pinkman
  module FormHelper
    module FormHelpers
      
      extend Pinkman::BaseHelper
      
      include Pinkman::ViewsHelpers::FormHelper
      
      define_helper :string do |attr_name,label=nil|
        label ||= attr_name.titleize
        render partial: 'pinkman/pinkman/form_input', locals: {attr_name: attr_name, label: label, input_options: {name: attr_name}}
      end
      
      define_helper :text do |attr_name,label=nil|
        label ||= attr_name.titleize
        render partial: 'pinkman/pinkman/form_textarea', locals: {attr_name: attr_name, label: label, textarea_options: {name: attr_name}}
      end
      
      define_helper :date do |attr_name,label=nil|
        label ||= attr_name.titleize
        render partial: 'pinkman/pinkman/form_input', locals: {attr_name: attr_name, label: label, input_options: {name: attr_name, type: 'date'}}
      end
      
      define_helper :datetime do |attr_name,label=nil|
        label ||= attr_name.titleize
        render partial: 'pinkman/pinkman/form_input', locals: {attr_name: attr_name, label: label, input_options: {name: attr_name}, type: 'time'}
      end
      
      define_helper :color do |attr_name,label=nil|
        label ||= attr_name.titleize
        render partial: 'pinkman/pinkman/form_input', locals: {attr_name: attr_name, label: label, input_options: {name: attr_name}}
      end
      
      define_helper :select do |attr_name,label,options_hash,html_options={}|
        if html_options.has_key?(:placeholder)
          placeholder = html_options[:placeholder]
          obligatory = html_options[:obligatory]
          html_options.delete(:placeholder)
        end
        obligatory = true if obligatory.nil?
        label ||= attr_name.titleize
        render partial: 'pinkman/pinkman/form_select', locals: {attr_name: attr_name, label: label, options_hash: options_hash, html_options: html_options, placeholder: placeholder, obligatory: obligatory}
      end
      
      define_helper :password do |attr_name,label=nil|
        label ||= attr_name.titleize
        render partial: 'pinkman/pinkman/form_input', locals: {attr_name: attr_name, label: label, input_options: {name: attr_name, type: 'password'}}
      end
      
      define_helper :number do |attr_name,label=nil|
        label ||= attr_name.titleize
        render partial: 'pinkman/pinkman/form_input', locals: {attr_name: attr_name, label: label, input_options: {name: attr_name, type: 'number'}}
      end
      
      define_helper :money do |attr_name,label=nil|
        label ||= attr_name.titleize
        render partial: 'pinkman/pinkman/form_input', locals: {attr_name: attr_name, label: label, input_options: {name: attr_name, type: 'number', min: 0, step: 0.01}}
      end
      
    end
  end
end