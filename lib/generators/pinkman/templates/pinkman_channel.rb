class PinkmanChannel < ApplicationCable::Channel
  
  # TO DO
  def scope
    :public
  end
  
  def room
    if params[:room].present?
      params[:room].to_sym
    else
      raise ArgumentError, 'Pinkman: Room not specified.'
    end
  end
  
end