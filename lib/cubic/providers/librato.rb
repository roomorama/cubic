require "librato/metrics"

module Cubic
  module Providers

    class Librato

      attr_reader :client, :namespace, :source, :queue_size, :_transaction_queue

      class MissingConfigurationError < StandardError
        def initialize(name)
          super(":librato provider requires a #{name} config")
        end
      end

      # Initializes a new instance of +Cubic::Providers::Librato+
      #
      # config - the hash passed as +provider_options+ when configuring +Cubic+.
      #
      # The Librato provider will use the following options:
      #
      # * email      - the email account on Librato [required]
      # * api_key    - the Librato API key [required]
      # * source     - the source to be used in the measurements sent to Librato [required]
      # * namespace  - a prefix to be used in all labels prior to sending to Librato [optional]
      # * queue_size - used for long-running processes. See more info below.
      #
      # In case any of the required options are missing, this class cannot be initialized,
      # and raises a +Cubic::Providers::Librato::MissingConfigurationError+.
      #
      # By default, this provider will synchonise measurements with Librato on each call
      # (i.e., one API call for each.) While this might suffice for small one-off scripts,
      # long-running processed such as web applications would benefit from sending measurements
      # in bulks. To achieve such goal, the +queue_size+ option can be used. It specifies the
      # number of measurements that must happen in order for the API call to happen.
      def initialize(config)
        email   = config[:email]   || raise(MissingConfigurationError.new(:email))
        api_key = config[:api_key] || raise(MissingConfigurationError.new(:api_key))
        @source = config[:source]  || raise(MissingConfigurationError.new(:source))

        @namespace = config[:namespace]
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
        result = yield
      ensure
        duration_in_ms = ((Time.now - start) * 1000).round
        val(label, duration_in_ms)
        result
      end

      def transaction
        @_transaction_queue = ::Librato::Metrics::Queue.new
        yield
      ensure
        no_failure { _transaction_queue.submit }
        @_transaction_queue = nil
      end

      private

      def submit(label, type, value)
        params = { namespaced(label) => { type: type, value: value, source: source } }

        no_failure do
          if queue
            queue.add(params)
          else
            ::Librato::Metrics.submit(params)
          end
        end
      end

      def no_failure
        yield
      rescue ::Librato::Metrics::ClientError, ::Librato::Metrics::ServerError
        # continue execution if Librato is unavailable
      end

      def namespaced(label)
        if namespace
          [namespace, label].join(".")
        else
          label
        end
      end

      def queue
        _transaction_queue || long_lived_queue
      end

      def long_lived_queue
        @long_lived_queue ||= queue_size && ::Librato::Metrics::Queue.new(autosubmit_count: queue_size)
      end

    end

  end
end
