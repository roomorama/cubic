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

  def self.config
    yield self.configuration
    self.provider = Cubic::Providers.build(self.configuration)
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

  def self.transaction(*args)
    provider.transaction(*args)
  end
end
