require "setup"

class TestNull < Minitest::Test

  attr_reader :provider

  def setup
    @provider = Cubic::Providers::Null.new
  end

  def test_inc
    assert_nil provider.inc("metric")
  end

  def test_val
    assert_nil provider.val("metric", 20)
  end

  def test_time
    result = provider.time("some computation") { 50.times { raise "error" rescue nil } }
    assert_equal 50, result
  end
end
