require "cubic/providers"

module Cubic
  Configuration = Struct.new(:provider, :provider_options)

  DEFAULT_PROVIDER = :memory

  class << self
    attr_writer :configuration, :provider

    def configuration
      @configuration ||= Configuration.new(DEFAULT_PROVIDER, {})
    end

    def provider
      @provider ||= Cubic::Providers.build(configuration)
    end
  end

  # Configures +Cubic+.
  #
  # Usage:
  #
  #   Cubic.config do |c|
  #     c.provider = :librato
  #     c.provider_options = { api_key: "..." }
  #   end
  #
  # Available providers:
  #
  #   * memory  - stores measurements in memory.
  #   * null    - test provider, being a no-op for all operations.
  #   * librato - uses Librato's API for metrics.
  def self.config
    yield self.configuration
    self.provider = Cubic::Providers.build(self.configuration)
  end

  # Performs an increment of the current value of a given label, indicating the
  # occurence of an event.
  #
  #   Cubic.inc("pageview")
  #
  # Increments by a larger amount are also possible:
  #
  #   Cubic.inc("objects.imported", by: 100)
  def self.inc(*args)
    provider.inc(*args)
  end

  # Adds a new data point associated with a given label. Over time, values associated
  # with a label will generate a time series that can be analysed.
  #
  #   Cubic.val("attempts", 4)
  def self.val(*args)
    provider.val(*args)
  end

  # Performs wall clock measurements a given operation, associating it with a name.
  #
  #   Cubic.time("batch_work") do
  #     # ...
  #   end
  #
  # At the end of the process, +batch_work+ will be used as a label with the duration
  # of the given block execution, in ms.
  def self.time(*args, &block)
    provider.time(*args, &block)
  end

  # Some providers allow data to be synchronised with the 3rd party API in real time.
  # That might not be ideal in the case where many measurements are performed within a
  # short period of time. The +transaction+ method allows the caller to group all measures
  # performed within the given block to be synchronised at once, at the end of the process.
  #
  #   Cubic.transaction do
  #     Cubic.inc("transaction")
  #
  #     # ...
  #
  #     Cubic.inc("transaction_end")
  #   end
  def self.transaction(*args, &block)
    provider.transaction(*args, &block)
  end
end
