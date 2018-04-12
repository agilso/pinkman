require 'rails/generators/base'

module Pinkman
  class ChannelGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    argument :class_name, type: :string, default: "nameHere"

    def generate_files
      template "channel.rb.erb", "app/channels/#{file_name}"
    end

    private

    def model_name
      class_name.camelize
    end
    
    def channel_name
      model_name + 'Channel'
    end

    def file_name
      class_name.underscore + "_channel.rb"
    end 
    
  end
end