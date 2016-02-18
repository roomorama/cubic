require "cubic/providers"

module Cubic
  Configuration = Struct.new(:provider, :provider_options, :queue_size)

  DEFAULT_PROVIDER = :memory

  class << self
    attr_writer :configuration, :provider

    def configuration
      @configuration ||= Configuration.new(DEFAULT_PROVIDER, {}, 0)
    end

    def provider
      @provider ||= Cubic::Providers.build(configuration)
    end
  end

  def self.config
    options = Configuration.new
    yield options

    self.configuration = options
    self.provider = Cubic::Providers.build(options)
  end

  def self.inc(*args)
    provider.inc(*args)
  end

  def self.val(*args)
    provider.val(*args)
  end

  def self.time(*args)
    provider.time(*args)
  end
end
