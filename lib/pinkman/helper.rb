module Pinkman
  module Helper
      
      def self.dispatcher helper
        @helper ||= PinkHelper.new(helper)
      end
      
      def self.study
        Proc.new do |*args,&block|
          ["args: #{args.length}",block_given?]
        end
      end
      
      def self.input hash, *args, &block
        name = hash[:name]
        hash[:type] ||= 'text'
        tag('input',hash.merge(data: {pinkey: pinkey, action: name}, value: write(name)), *args, &block)
      end

      def self.textarea hash, *args
        name = hash[:name]
        content_tag('textarea',hash.merge(data: {pinkey: pinkey, action: name}, value: write(name)), *args) do 
          write_and_escape_sync(name)
        end
      end
      
      
      def self.template path, &block
        # definition mode
        if block_given?
          name = path.to_s
          id = (/(?:-template)$/ =~ name) ? name : (name + '-template')
          content_tag('script',{id: id, type: 'text/p-template'}, &block)
        # rendering template partial mode
        else
          render partial: "pinkman/#{path}"
        end
      end
      
      def self.partial path, &block
        # definition mode
        name = path.to_s
        id = (/(?:-template)$/ =~ name) ? name : (name + '-template')
        if block_given?
          content_tag('script',{id: id, type: 'text/p-partial', class: 'p'}, &block)
        # rendering template partial mode
        else
          raw("{{ partial(#{id}) }}")
        end
      end
      
      def self.load_templates
        if Rails
          dir = Rails.root.join('app','views','pinkman')
          files = Dir.glob(dir.join('**/_*')).map do |f|    
            f.sub(Regexp.new("#{dir.to_s}(?:[\\\/])"),'').sub(/_/,'')
          end
          raw(files.map{|f| template(f)}.join("\n"))
        else
          raise 'Rails application not found.'
        end
      end

      def self.wrap_in
        # binding.pry
        Proc.new do |tag,block|
          raw "\n{{# #{tag} }}\n \t #{capture(&block)} \n{{/ #{tag} }}\n" if block   
        end
      end

      def self.collection &block
        wrap_in('collection',&block)
      end

      def self.each &block
        collection(&block)
      end

      def self.write
        Proc.new do |string|
          raw("{{#{string}}}")
        end
      end
      singleton_class.send :alias_method, :w, :write
      
      def self.write_and_escape_sync string
        raw("{{. #{string} }}")
      end
      singleton_class.send :alias_method, :_w, :write_and_escape_sync

      def self.pinkey 
        w('pinkey')
      end

      def self._if condition, &block
        wrap_in(condition,&block)
      end

      def self._unless condition, &block
        raw "\n{{^ #{condition} }}\n \t #{capture(&block)} \n{{/ #{condition} }}\n" if block_given?    
      end
      
      # def self.capture(var, enumerable = nil, &block)
      #   value = enumerable ? enumerable.map(&block) : yield
      #   block.binding.eval("lambda {|x| #{var} = x }").call(value)
      #   nil
      # end
      
      class PinkHelper
        attr_accessor :helper
        
        def initialize value
          @helper = value
        end
        
        def method_missing m, *args, &block
          if Pinkman::Helper.respond_to?(m)
            # binding.pry
            helper.instance_exec(*args,block,&Pinkman::Helper.send(m))
          else
            super(m)
          end
        end
      end
  end
end