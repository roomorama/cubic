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

  def test_namespaced
    namespace = @redis_provider.namespaced("dev.metric")
    assert_equal "dev.metric", namespace
  end

  def test_namespaced_when_label_content_weird_characters
    namespace = @redis_provider.namespaced("weird_metric.metric%^")
    assert_equal "weird_metric.metric", namespace
  end

  def test_namespaced_keep_dash_character
    namespace = @redis_provider.namespaced("!dash-metric.metric%^")
    assert_equal "dash-metric.metric", namespace
  end

  def test_namespaced_remove_spaces
    namespace = @redis_provider.namespaced("     a   metric   %%%")
    assert_equal "ametric", namespace
  end

  def test_namespaced_included_digits
    namespace = @redis_provider.namespaced("metric_with_digit012345")
    assert_equal "metric_with_digit012345", namespace
  end

  def test_namespaced_filter_default_namespace
    redis_provider = Cubic::Providers::Redis.new({namespace: " namespace!@#$%^&*()"})
    namespace = redis_provider.namespaced("a%%%%\"metric")
    assert_equal "namespace.ametric", namespace
  end

  def test_namespaced_with_totally_invalid_label_and_namespace
    redis_provider = Cubic::Providers::Redis.new({namespace: "•¡™£∞§¶ª({}*+)"})
    namespace = redis_provider.namespaced("%%%%\"\'ƒ©˙∫ç`™¡∂ƒ∫√µ≤˜≤∆˚˙¬∆¬˚∆˙¨øˆ¨ø")
    assert_equal '.', namespace
  end
end
