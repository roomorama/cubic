require 'yaml'
require 'ostruct'

# Worker configuration
#    Can be config with a config_file, which is specified by a +path+,
#    or a following +block+
#
# @example pass a config file
#
#   Cubic::Workers::Config.configure("/path_to_config/config_file.yml")
#
# @examle pass a block
#
#   Cubic::Workers::Config.configure do |c|
#     c.email      = "admin@gmail.com"
#     c.api_key    = "124"
#     c.interval   = 1
#     c.url        = "redis://localhost:6379/15"
#     c.queue_size = 10
#   end
module Cubic
  module Workers
    class Config
      def self.configure(path, &block)
        new(path, &block).load!
      end

      attr_reader :path, :block

      def initialize(path = nil, &block)
        @path = path
        @block = block
      end

      def load!
        if block
          self.instance_eval(&block)
        elsif path
          @config = OpenStruct.new load_from_file
        else
          {}
        end
      end

      def to_h
        config.to_h
      end

      def config
        @config ||= OpenStruct.new
      end

      def load_from_file
        YAML.load_file path
      end
    end
  end
end
