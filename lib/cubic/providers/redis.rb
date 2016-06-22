module Cubic
  module Providers
    class Redis

      def initialize(*)
      end

      def inc(*)
      end

      alias_method :counter, :inc

      def val(*)
      end

      def time(*)
        yield
      end

      def transaction
        yield
      end

      def query(*)
      end

    end

  end
end
