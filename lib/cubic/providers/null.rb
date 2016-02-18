module Cubic
  module Providers

    class Null

      def initialize(*)
      end

      def inc(*)
      end

      def val(*)
      end

      def time(*)
      end

      def transaction
        yield
      end

      def query(*)
      end

    end

  end
end
