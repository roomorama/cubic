module Cubic
  module Providers

    # +Cubic::Providers::NullProvider+
    #
    # Provides a null implmentation for measurements. Ignores all calls to
    # the interface methods.
    class Null

      def initialize(*)
      end

      def inc(*)
      end

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
