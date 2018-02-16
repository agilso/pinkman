require 'rails/generators/base'

module Pinkman
  class TemplateGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    argument :pink_template_arg, type: :string
    
    def normalize_argument
      self.pink_template_arg = pink_template_arg.downcase.gsub(' ','_').strip.squeeze('_').gsub(/:/,'/')
    end

    def generate_pink_template
      template template_path, file_path
    end

    private
    
    def template_engine_extension
      begin Rails.configuration.generators.options[:rails][:template_engine].to_s rescue 'erb' end
    end
    
    def template_path
      "pink_template.html.#{template_engine_extension}.erb"
    end
    
    def file_path
      path = (pink_template_arg + ".html.#{template_engine_extension}").split('/')
      path[path.length-1] = '_' + path.last
      Rails.root.join('app','views','pinkman',*path.map{|p| p})
    end
    
    def path
      file_path.to_s.sub(Rails.root.to_s,'')
    end
    
    def controller_name
      pink_template_arg.split('/').join('-').gsub(/[_\/]/,'-')
    end
    
    def pink_template_name
      controller_name
    end  

  end
end

