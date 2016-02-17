require "librato/metrics"

module Cubic
  module Providers

    class Librato

      attr_reader :client, :namespace, :source

      class MissingConfiguration < StandardError
        def initialize(name)
          super(":librato provider requires a #{name} config")
        end
      end

      def initialize(config)
        email   = config[:email]   || raise(MissingConfiguration.new(:email))
        api_key = config[:api_key] || raise(MissingConfiguration.new(:api_key))

        @namespace = config[:namespace]
        @source = config[:source]

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
        ::Librato::Metrics.submit(namespaced(label) => { type: type, value: value, source: source })
      end

      def namespaced(label)
        if namespace
          [namespace, label].join(".")
        else
          label
        end
      end

    end

  end
end
