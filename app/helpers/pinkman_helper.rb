module PinkmanHelper

  def input hash, *args, &block
    name = hash[:name]
    tag('input',hash.merge(data: {pinkey: pinkey, action: name}, value: write(name)), *args, &block)
  end
  
  def template path
    render partial: "pinkman/#{path}"
  end

  def wrap_in tag, &block
    raw "\n{{# #{tag} }}\n \t #{capture(&block)} \n{{/ #{tag} }}\n" if block_given?    
  end

  def collection &block
    wrap_in('collection',&block)
  end

  def write string
    raw("{{ #{string} }}")
  end

  def w *args
    write(*args)
  end

  def pinkey 
    w('pinkey')
  end

  def p_if condition, &block
    raw "\n{{#if #{condition}}}\n \t #{capture(&block)} \n{{/if}}\n" if block_given?    
  end

  def p_then &block
    capture(&block)
  end

  def p_else &block
    raw "\n{{else}}\n \t #{capture(&block)}" if block_given?    
  end

  def p_unless
  end


end