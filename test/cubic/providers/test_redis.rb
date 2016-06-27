require_relative "../../setup"
require "cubic/providers/redis"

class Redis
  def self.result
    @@result
  end

  def incrby(label, by)
    @@result = [label, by]
  end
end

class TestRedis < Minitest::Test
  def setup
    @redis_provider = Cubic::Providers::Redis.new({})
  end

  def test_inc
    result = @redis_provider.inc("dev.metric", by: 3)
    assert_equal ::Redis.result, ["dev.metric", 3]
  end
end
