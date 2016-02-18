require "librato/metrics"

module Cubic
  module Providers

    class Librato

      attr_reader :client, :namespace, :source, :queue_size

      class MissingConfigurationError < StandardError
        def initialize(name)
          super(":librato provider requires a #{name} config")
        end
      end

      def initialize(config)
        email   = config[:email]   || raise(MissingConfigurationError.new(:email))
        api_key = config[:api_key] || raise(MissingConfigurationError.new(:api_key))

        @namespace = config[:namespace]
        @source = config[:source]
        @queue_size = config[:queue_size]

        ::Librato::Metrics.authenticate(email, api_key)
      end

      def inc(label, by: 1)
        submit(label, :counter, by)
      end

      def val(label, value)
        submit(label, :gauge, value)
      end

      def time(label)
        start = Time.now
        yield
      ensure
        duration_in_ms = ((Time.now - start) * 1000).round
        val(label, duration_in_ms)
      end

      private

      def submit(label, type, value)
        params = { namespaced(label) => { type: type, value: value, source: source } }

        if queue
          queue.add(params)
        else
          ::Librato::Metrics.submit(params)
        end
      end

      def namespaced(label)
        if namespace
          [namespace, label].join(".")
        else
          label
        end
      end

      def queue
        @queue ||= queue_size && ::Librato::Metrics::Queue.new(autosubmit_count: queue_size)
      end

    end

  end
end
