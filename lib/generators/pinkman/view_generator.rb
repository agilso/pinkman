require 'rails/generators/base'

module Pinkman
  class ViewGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    argument :view_arg, type: :string
    
    def normalize_argument
      self.view_arg = view_arg.downcase.gsub(' ','_').strip.squeeze('_').gsub(/:/,'/')
    end

    def generate_view
      template template_path, file_path
    end

    private
    
    def template_engine_extension
      begin Rails.configuration.generators.options[:rails][:template_engine].to_s rescue 'erb' end
    end
    
    def template_path
      "view.html.#{template_engine_extension}.erb"
    end
    
    def file_path
      path = (view_arg + ".html.#{template_engine_extension}").split('/')
      path[path.length-1] = '_' + path.last
      Rails.root.join('app','views','pinkman',*path.map{|p| p})
    end
    
    def path
      file_path.to_s.sub(Rails.root.to_s,'')
    end
    
    def controller_name
      view_arg.split('/').last.gsub('_','-')
    end
    
    def view_name
      view_arg.split('/').last.gsub('_','-')
    end  

  end
end

