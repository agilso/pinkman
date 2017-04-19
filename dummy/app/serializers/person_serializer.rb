class PinkmanScope
  attr_accessor :read, :write, :access

  def read_attributes *args
    self.read = args
  end

  def write_attributes *args
    self.write = args
  end

  def access_actions *args
    self.access = args
  end

  def can_read? attribute
    read.include?(:all) or read.include?(attribute.to_sym)
  end

  def can_write? attribute
    write.include?(:all) or write.include?(attribute.to_sym)
  end

  def can_access? action
    access.include?(:all) or access.include?(action.to_sym)
  end

end

class PinkmanSerializer
  @@scopes = {}

  def self.scope name, &block
    if block_given?
      @@scopes[name.to_sym] ||= PinkmanScope.new
      yield(@@scopes[name.to_sym]) 
    else
      @@scopes[name.to_sym]
    end
  end

end

class PersonSerializer < PinkmanSerializer
  scope :all do |can|
    can.read_attributes :name, :id, :age
    can.write_attributes :all
    can.access_actions :all
  end
end
