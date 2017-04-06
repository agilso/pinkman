require 'sprockets'
require 'uglifier'

class Assets
  def self.app_environment
    unless @app_environment
      @app_environment ||= Sprockets::Environment.new
      @app_environment.append_path Pinkman.root.join('app','assets','javascripts')
      @app_environment.js_compressor  = :uglify
    end
    @app_environment
  end

  def self.spec_environment
    unless @spec_environment
      @spec_environment ||= Sprockets::Environment.new
      @spec_environment.append_path Pinkman.root.join('spec','coffeescripts')
    end
    @spec_environment
  end
end