require "setup"
require "cubic/workers/librato"

class Redis
  def keys(*)
    ["foo", "bar"]
  end

  def mget(*)
    [1, 2]
  end
end

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

class TestBaseWorker < Minitest::Test
  def setup
    config = {
      email: "librato@example.org",
      api_key: "12345",
      source: "test",
      namespace: "dev"
    }

    @worker = Cubic::Workers::Librato.new(config)
  end

  def test_load_redis_metrics
    result = @worker.load_redis_metrics
    assert_includes result.names, "foo"
    assert_includes result.names, "bar"
  end

  def test_submit_librato
    metrics = Cubic::Workers::Librato::Metric.new(["foo"], [1])
    @worker.submit_librato(metrics)
    result = Librato::Metrics._calls
    assert_instance_of Array, result
  end
end
