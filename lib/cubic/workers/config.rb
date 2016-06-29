require 'yaml'
require 'ostruct'

module Cubic
  module Workers
    class Config
      def self.configure(path, &block)
        new(path, &block).load
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

      def config
        @config ||= OpenStruct.new
      end

      def load_from_file
        YAML.load_file path
      end
    end
  end
end
