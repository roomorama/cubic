module Cubic
  module Providers

    autoload :Null, "cubic/providers/null"
    autoload :Memory, "cubic/providers/memory"
    autoload :Librato, "cubic/providers/librato"

    class UnrecognizedProviderError < StandardError
      def initialize(provider)
        super("Unknown provider: #{provider.to_s}")
      end
    end

    def self.build(config)
      case config.provider
      when :null
        Null.new
      when :memory
        Memory.new
      when :librato
        Librato.new(config.provider_options)
      else
        raise UnrecognizedProviderError.new(config.provider)
      end
    end

  end
end
