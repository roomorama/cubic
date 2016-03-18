require "setup"

class TestMemory < Minitest::Test

  attr_reader :provider

  def setup
    @provider = Cubic::Providers::Memory.new
  end

  def test_inc
    provider.inc("metric")
    provider.inc("metric")

    provider.inc("metric_multiple", by: 3)

    assert_equal 2, provider.query("metric")
    assert_equal 3, provider.query("metric_multiple")
  end

  def test_val
    provider.val("metric", 20)
    provider.val("metric",  30)
    provider.val("metric", 0)

    provider.val("other metric", "yes")

    assert_equal [20, 30, 0], provider.query("metric")
    assert_equal ["yes"], provider.query("other metric")
  end

  def test_time
    result = provider.time("some computation") { 50.times { raise "error" rescue nil } }

    assert_equal 50, result
    assert provider.query("some computation")
  end

  def test_query
    provider.inc("metric")

    assert_equal 1, provider.query("metric")
    assert_nil provider.query("invalid metric")
  end
end
