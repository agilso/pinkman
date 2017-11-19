module PinkmanHelper

  def input hash, *args, &block
    name = hash[:name]
    hash[:type] ||= 'text'
    tag('input',hash.merge(data: {pinkey: pinkey, action: name}, value: write(name)), *args, &block)
  end

  def textarea hash, *args
    name = hash[:name]
    content_tag('textarea',hash.merge(data: {pinkey: pinkey, action: name}, value: write(name)), *args) do 
      write_and_escape_sync('name')
    end
  end
  
  
  def template path, &block
    # definition mode
    if block_given?
      name = path.to_s
      id = (/(?:-template)$/ =~ name) ? name : (name +'-template')
      content_tag('template',{id: id, type: 'text/p-template'}, &block)
    # rendering template partial mode
    else
      render partial: "pinkman/#{path}"
    end
  end
  
  def partial path, &block
    # definition mode
    name = path.to_s
    id = (/(?:-partial)$/ =~ name) ? name : (name +'-partial')
    if block_given?
      content_tag('template',{id: id, type: 'text/p-partial', class: 'p'}, &block)
    # rendering template partial mode
    else
      raw("{{ partial(#{id}) }}")
    end
  end
  
  def load_templates
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

  def wrap_in tag, &block
    raw "\n{{# #{tag} }}\n \t #{capture(&block)} \n{{/ #{tag} }}\n" if block_given?    
  end

  def collection &block
    wrap_in('collection',&block)
  end

  def each &block
    collection(&block)
  end

  def write string
    raw("{{#{string}}}")
  end
  alias w write
  
  
  
  def write_and_escape_sync string
    raw("{{.#{string}}}")
  end
  alias _w write_and_escape_sync

  def pinkey 
    w('pinkey')
  end

  def _if condition, &block
    wrap_in(condition,&block)
  end

  def _unless condition, &block
    raw "\n{{^ #{condition} }}\n \t #{capture(&block)} \n{{/ #{condition} }}\n" if block_given?    
  end

end