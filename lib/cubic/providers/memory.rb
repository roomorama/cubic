module Cubic
  module Providers

    # +Cubic::Providers::Memory+
    #
    # The memory provider stores all measurements in primary memory. It is intended to
    # be a provider for test experiments.
    class Memory
      attr_reader :storage

      def initialize(*)
        @storage = {}
      end

      def inc(label, by: 1)
        storage[label] ||= 0
        storage[label] += by
      end
      alias_method :counter, :inc

      def val(label, value)
        storage[label] ||= []
        storage[label] << value
      end

      def time(label)
        start = Time.now
        result = yield
      ensure
        duration_in_ms = ((Time.now - start) * 1000).round
        val(label, duration_in_ms)
        result
      end

      def transaction
        yield
      end

      def query(label)
        storage[label]
      end

    end

  end
end
