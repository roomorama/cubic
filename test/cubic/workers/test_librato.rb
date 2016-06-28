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

class TestBaseWorker < Minitest::Test
  def setup
    @worker = Cubic::Workers::Librato.new
  end

  def test_load_redis_metrics
    result = @worker.load_redis_metrics
    assert_includes result.names, "foo"
    assert_includes result.names, "bar"
  end
end
