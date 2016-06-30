module Cubic
  module Providers

    autoload :Null, "cubic/providers/null"
    autoload :Memory, "cubic/providers/memory"
    autoload :Librato, "cubic/providers/librato"
    autoload :Redis, "cubic/providers/redis"

    class UnrecognizedProviderError < StandardError
      def initialize(provider)
        super("Unknown provider: #{provider.to_s}")
      end
    end

    # returns an instantiated and configured provider that matches
    # the +config+ given.
    #
    # config - a +Cubic::Configuration+ object
    #
    # Raises +Cubic::Providers::UnrecognizedProviderError+ in case
    # the provider is not known.
    def self.build(config)
      case config.provider
      when :null
        Null.new
      when :memory
        Memory.new
      when :librato
        Librato.new(config.provider_options)
      when :redis
        Redis.new(config.provider_options)
      else
        raise UnrecognizedProviderError.new(config.provider)
      end
    end

  end
end
