require_relative 'base_helper.rb'

module Pinkman
  module ViewsHelpers
    module WriterHelper
      
      extend BaseHelper
      
      define_helper :write do |string|
        raw "{{ #{string} }}"
      end
      define_helper_alias :w, :write
      
      define_helper :write_and_escape_sync do |string|
        raw("{{. #{string} }}")
      end
      define_helper_alias :_w, :write_and_escape_sync
      
      define_helper :wrap_in do |tag,block=nil|
        raw "\n{{# #{tag} }}\n \t #{capture(&block)} \n{{/ #{tag} }}\n" if block.is_a?(Proc)
      end
      define_helper_alias :wrap, :wrap_in
      
      define_helper :pinkey do
        p.write('pinkey')
      end
      define_helper_alias :key, :pinkey
      
    end
  end
end