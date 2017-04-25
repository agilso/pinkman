require 'active_model_serializers'

module Pinkman
  module Serializer
    class Array
      
      attr_accessor :params

      def self.serialize *args
        binding.pry
        args.first.map {|obj| obj.serialize_for(args[1][:scope],args[1][:params])} if args.first.is_a? Array and args.length > 1 and args[1].is_a?(Hash) and args[1][:scope]
      end

    end
  end
end