require 'digest'

class Pinkman::Broadcaster
  
  include ActiveModel::Validations
  
  attr_accessor :model, :scope, :record
  validates :model, :room, :scope, presence: true
    
    
  def initialize options
    self.scope = options[:scope]
    self.model = options[:model]
    true  
  end
  
  def self.broadcasters
    @broadcasters ||= {}
  end 
  
  def self.broadcast room, scope, action, record
    ActionCable.server.broadcast room_name_from_record(room,record), {action: action, data: record.json_hash(scope)}
  end
  
  def self.stream channel, scope, params
    if params[:room].present?
      broadcaster = broadcasters[params[:room].to_sym]
      if broadcaster.present?
        channel.stream_from(room_name_from_params(broadcaster,params))
      else
        raise "Room '#{params[:room]}' not found."
      end
    else
      raise 'Room not specified through client.'
    end
  end
  
  def self.room_name_from_params broadcaster, params
    if params[:filter_by].is_a? String
      broadcaster.encrypt(broadcaster.room,params[:filter_by])
    elsif params[:filter_by].is_a? Array
      broadcaster.encrypt(broadcaster.room, params[:filter_by].join(' '))
    else
      broadcaster.room
    end
  end
  
  def self.room_name_from_record room_name, record
    broadcaster = broadcasters[room_name.to_sym]
    if broadcaster
      broadcaster.room_name(record)
    else
      raise "#{room_name} not found/declared"
    end
  end
  
  def room room_name=nil
    if room_name.present?
      @room = room_name
    else
      @room
    end
  end
  
  def filter_by *args
    if args.any?
      @filter_by = args
    else
      @filter_by ||= []
    end
  end
  
  def save
    valid? and (self.class.broadcasters[room.to_sym] = self) and set_callbacks
  end
  
  def get_record params
    if filter_by.any? and params[:filter_by].present?
      where_hash = {}
      filter_by.each_with_index {|attribute,i| where_hash[attribute] = params[:filter_by][i] }
      model.where(where_hash).first if model.where(where_hash).any?
    end
  end
  
  def encrypt_room_name(record)
    passphrase = filter_by.map { |attribute| record.send(attribute) }.join(' ')
    encrypt(room,passphrase)
  end
  
  def encrypt room_name, passphrase
    md5(room_name.to_s + 'pinkroom' + passphrase)
  end
  
  def room_name(record=nil)
    (record.present? and filter_by.any?) ? encrypt_room_name(record) : room
  end
  
  def md5 val
    Digest::MD5.hexdigest(val) 
  end
  
  def set_callbacks
    if valid?
      ['create','update','destroy'].each do |action|
        current_room = room
        current_scope = scope
        model.define_method "broadcast_#{action}_to_#{room}" do
          Pinkman::Broadcaster.broadcast(current_room, current_scope, action, self)
        end  
        
        model.send("after_#{action}".to_sym, "broadcast_#{action}_to_#{room}".to_sym)
      
      end
      true
    end
  end
  
end