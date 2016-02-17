require "cubic"
require "minitest/autorun"

class TestCubic < Minitest::Test

  def teardown
    Cubic.configuration = nil
  end

  def test_default_configuration
    assert_equal :librato, Cubic.configuration.provider
    assert_equal 0, Cubic.configuration.queue_size
  end

  def test_customising_configuration
    Cubic.config do |c|
      c.provider = :librato
      c.queue_size = 20
    end

    assert_equal :librato, Cubic.configuration.provider
    assert_equal 20, Cubic.configuration.queue_size
  end

end
