module Cubic
  module Providers
    class Redis
      def initialize(config)
      end

      def inc(label, by: 1)
      end

      alias_method :counter, :inc

      def val(label, value)
      end

      def inc(label, by: 1)
      end
    end
  end
end
