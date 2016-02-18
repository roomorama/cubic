require "cubic/providers"

module Cubic
  Configuration = Struct.new(:provider, :provider_options, :queue_size)

  DEFAULT_PROVIDER = :memory

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new(DEFAULT_PROVIDER, {}, 0)
    end
  end


  def self.config
    options = Configuration.new
    yield options

    self.configuration = options
  end
end
