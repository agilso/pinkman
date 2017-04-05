module PinkmanHelper
  
  def pinkman_template path
    render partial: "pinkman/#{path}"
  end

  def pinkman_enclose_with(tag,&block) 
    raw "\n<<# #{tag} >>\n \t #{capture(&block)} \n<</ #{tag} >>\n" if block_given?    
  end

  def pinkman *args
    pinkman_attr(*args)
  end

  def pinkman_attr string
    raw("<< #{string} >>")
  end

  def pinkey 
    pinkman_attr('pinkey')
  end


end