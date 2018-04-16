require 'pinkman/broadcaster'

class PinkmanChannel < ActionCable::Channel::Base

  def scope 
    :public
  end
  
  def self.model 
    @model || self.to_s.gsub('Channel','').constantize
  end
  
  def self.model= model
    @model = model
  end
  
  def self.rooms
    @rooms ||= []
  end
  
  def self.broadcast scope
    broadcasting = Pinkman::Broadcaster.new(scope: scope, model: model)
    if block_given?
      yield(broadcasting)
      if broadcasting.save
        broadcasting
      else
        raise "Pinkman: Error trying to broadcasting to #{broadcasting.room}."
      end
    else
      raise 'PinkmanChannel.broadcast: no block given'
    end
  end
  
  def model
    self.class.model
  end
  
  def subscribed
    stream
  end
  
  def unsubscribed
    stop_all_streams
  end
  
  def stream
    Pinkman::Broadcaster.stream(self,scope,params)
  end


end