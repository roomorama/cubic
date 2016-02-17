module Cubic
  Configuration = Struct.new(:provider, :queue_size)

  DEFAULT_PROVIDER = :librato

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new(DEFAULT_PROVIDER, 0)
    end
  end


  def self.config
    options = Configuration.new
    yield options

    self.configuration = options
  end
end
