require 'rails/generators/base'

module Pinkman
  class PinkmanChannelGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def copy_pinkman_channel_file
      template "pinkman_channel.rb", "app/channels/pinkman_channel.rb"
    end

  end
end