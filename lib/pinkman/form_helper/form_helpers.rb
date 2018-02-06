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
        render partial: 'pinkman/pinkman/form_input', locals: {attr_name: attr_name, label: label, input_options: {name: attr_name}}
      end
      
      define_helper :date do |attr_name,label=nil|
        label ||= attr_name.titleize
        render partial: 'pinkman/pinkman/form_input', locals: {attr_name: attr_name, label: label, input_options: {name: attr_name}}
      end
      
      define_helper :datetime do |attr_name,label=nil|
        label ||= attr_name.titleize
        render partial: 'pinkman/pinkman/form_input', locals: {attr_name: attr_name, label: label, input_options: {name: attr_name}}
      end
      
      define_helper :select do |attr_name,label=nil,teste=nil|
        label ||= attr_name.titleize
        render partial: 'pinkman/pinkman/form_input', locals: {attr_name: attr_name, label: label, input_options: {name: attr_name}}
      end
      
      define_helper :password do |attr_name,label=nil|
        label ||= attr_name.titleize
        render partial: 'pinkman/pinkman/form_input', locals: {attr_name: attr_name, label: label, input_options: {name: attr_name}}
      end
      
      define_helper :number do |attr_name,label=nil|
        label ||= attr_name.titleize
        render partial: 'pinkman/pinkman/form_input', locals: {attr_name: attr_name, label: label, input_options: {name: attr_name}}
      end
      
      define_helper :money do |attr_name,label=nil|
        label ||= attr_name.titleize
        render partial: 'pinkman/pinkman/form_input', locals: {attr_name: attr_name, label: label, input_options: {name: attr_name}}
      end
      
    end
  end
end