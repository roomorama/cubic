require "setup"
require "cubic/providers/librato"

# stub `submit` method to be able to check on performed calls
# and avoid actually hitting an external API.
module Librato::Metrics
  class << self
    def reset!
      @_calls = []
    end

    def _calls
      @_calls ||= []
    end

    def submit(options)
      _calls << options
    end
  end
end

class TestLibrato < Minitest::Test

  attr_reader :provider

  def setup
    @provider = Cubic::Providers::Librato.new(email: "librato@example.org", api_key: "12345")
    Librato::Metrics.reset!
  end

  def test_requires_email
    assert_raises(Cubic::Providers::Librato::MissingConfigurationError) {
      Cubic::Providers::Librato.new(api_key: "12345")
    }
  end

  def test_requires_api_key
    assert_raises(Cubic::Providers::Librato::MissingConfigurationError) {
      Cubic::Providers::Librato.new(email: "librato@example.org")
    }
  end

  def test_namespacing
    provider = Cubic::Providers::Librato.new(email: "librato@example.org", api_key: "12345", namespace: "dev")
    provider.inc("metric")

    assert_equal [{ "dev.metric" => { type: :counter, value: 1, source: nil } }], Librato::Metrics._calls
  end

  def test_source
    provider = Cubic::Providers::Librato.new(email: "librato@example.org", api_key: "12345", source: "m1")
    provider.inc("metric")

    assert_equal [{ "metric" => { type: :counter, value: 1, source: "m1" } }], Librato::Metrics._calls
  end

  def test_inc
    provider.inc("metric")
    provider.inc("metric")
    provider.inc("metric_multiple", by: 3)

    assert_equal [
      { "metric"          => { type: :counter, value: 1, source: nil } },
      { "metric"          => { type: :counter, value: 1, source: nil } },
      { "metric_multiple" => { type: :counter, value: 3, source: nil } }
    ], Librato::Metrics._calls
  end

  def test_val
    provider.val("metric", 20)
    provider.val("metric", 30)
    provider.val("metric", 0)

    assert_equal [
      { "metric" => { type: :gauge, value: 20, source: nil } },
      { "metric" => { type: :gauge, value: 30, source: nil } },
      { "metric" => { type: :gauge, value: 0, source: nil } }
    ], Librato::Metrics._calls
  end

  def test_time
    provider.time("metric") { 50.times { raise "error" rescue nil } }
    calls = Librato::Metrics._calls

    assert_equal 1, calls.size

    call = calls.first
    name = call.keys.first
    value = call.values.first

    assert_equal "metric", name
    assert_equal :gauge, value[:type]
    assert value[:value]
    assert_nil value[:source]
  end

  class Librato::Metrics::Queue
    attr_reader :_calls

    # overriding the `add` method to inspect its invokations.
    def add(options)
      @_calls ||= []
      _calls << options
    end
  end

  def test_queue
    provider = Cubic::Providers::Librato.new(email: "librato@example.org", api_key: "12345", queue_size: 20)

    provider.inc("metric")
    provider.val("other_metric", 20)
    calls = provider.send(:queue)._calls

    assert_equal [
      { "metric"       => { type: :counter, value: 1, source: nil } },
      { "other_metric" => { type: :gauge, value: 20, source: nil } }
    ], calls
  end

end
