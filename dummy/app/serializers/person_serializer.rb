class PersonSerializer < Pinkman::Serializer::Base
  
  
  scope :all do |can|
    can.read_attributes :name, :age, :id, :email, :bla
    can.write_attributes :name
    can.access_actions :all
  end

  scope :admin do |can|
    can.read_attributes :all, :bla
    can.write_attributes :all
    can.access_actions :all
  end

  def bla
    if scope == :all
      'bla'
    elsif scope == :admin
      'id: ' + object.id.to_s
    end
  end

end
