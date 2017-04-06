class FooSerializer < PinkmanSerializer
  
  has_one :bar

  scope 'blank' do
    read :id
  end

  scope :user do
    read :first_name, :last_name, :age, :gender, :full_name
    write :last_name
  end

  scope :admin do
    read :all
    write :all
  end

  def full_name
    if variable.present? and variable == 'secret'
      'My full name is a secret, Sir.'
    else
      "#{object.first_name} #{object.last_name}"
    end
  end

  def password
    if scope == :secure
      object.hashed_password
    elsif scope == :insecure
      object.pure_password
    end
  end

end