require_relative "../../setup"
require "cubic/providers/redis"

class Redis
  def self.result
    @@result
  end

  def incrby(label, by)
    @@result = [label, by]
  end

  def set(label, value)
    @@result = [label, value]
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

  def test_val
    result = @redis_provider.val("dev.metric", 5)
    assert_equal ::Redis.result, ["dev.metric", 5]
  end

  def test_time
    result = @redis_provider.time("dev.metric") do
      true
    end

    assert_equal ::Redis.result, ["dev.metric", 0]
    assert_equal true, result
  end
end
