require_relative '../base_helper.rb'

module Pinkman
  module ViewsHelpers
    module TemplateHelper
      
      extend Pinkman::BaseHelper
      
      define_helper :template  do |path, block=nil|
        # definition mode
        if block.is_a?(Proc)
          name = path.to_s
          id = (/(?:-template)$/ =~ name) ? name : (name + '-template')
          content_tag('script',{id: id, type: 'text/p-template'},&block)
        # rendering mode
        else
          render partial: "pinkman/#{path}"
        end
      end
      
      define_helper :content_tag do |*args|
        block = args.pop if args.last.is_a?(Proc)
        if block
          content_tag(*args,&block)
        else
          content_tag(*args)
        end
      end
       
      define_helper :partial do |path, block=nil|
        # definition mode
        name = path.to_s
        id = (/(?:-template)$/ =~ name) ? name : (name + '-template')
        if block.is_a?(Proc)
          content_tag('script',{id: id, type: 'text/p-partial', class: 'p'},&block)
        # rendering template partial mode
        else
          raw("{{ partial(#{id}) }}")
        end
      end
      
      define_helper :load_templates do |dir_path=nil|
        if Rails
          pinkman_views_dir_path = Rails.root.join('app','views','pinkman')
          selected_dir_path = pinkman_views_dir_path
          selected_dir_path = selected_dir_path.join(dir_path.to_s) if dir_path.class.in?([String,Symbol])
          files = Dir.glob(selected_dir_path.join('**/_*')).map do |f|    
            f.sub(Regexp.new("#{pinkman_views_dir_path.to_s}(?:[\\\/])"),'').sub(/_/,'')
          end
          raw(files.map{|f| p.template(f)}.join("\n"))
        else
          raise 'Rails application not found.'
        end
      end
    end
  end
end