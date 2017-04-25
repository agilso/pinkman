 require_relative 'serializer/base'

 module Pinkman
  module Serializer

    def self.array *args
      args.first.map {|obj| obj.serialize_for(args[1][:scope],args[1][:params])} if args.first.methods.include?(:map) and args.length > 1 and args[1].is_a?(Hash) and args[1][:scope]
    end

  end
end