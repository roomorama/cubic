require "setup"

class TestCubic < Minitest::Test

  class TestProvider
    attr_reader :calls

    def initialize
      @calls = []
    end

    def inc(*args)
      calls << [:inc, args]
    end

    def val(*args)
      calls << [:val, args]
    end

    def time(*args, &block)
      calls << [:time, args]
    end

    def transaction(*args)
      calls << [:transaction, args]
    end
  end


  attr_reader :test_provider

  def setup
    @test_provider = TestProvider.new
  end

  def teardown
    Cubic.configuration = nil
    Cubic.provider = nil
  end

  def test_default_configuration
    assert_equal :memory, Cubic.configuration.provider
    assert_equal({}, Cubic.configuration.provider_options)
  end

  def test_default_provider
    assert_instance_of Cubic::Providers::Memory, Cubic.provider
  end

  def test_customising_configuration
    Cubic.config do |c|
      c.provider = :memory
      c.provider_options = { fast: true }
    end

    assert_equal :memory, Cubic.configuration.provider
    assert_equal({ fast: true }, Cubic.configuration.provider_options)
  end

  def test_delegate_inc
    Cubic.provider = test_provider

    Cubic.inc("metric")
    Cubic.inc("metric_multiple", by: 2)

    assert_equal [
      [:inc, ["metric"]],
      [:inc, ["metric_multiple", { by: 2 }]]
    ], test_provider.calls
  end

  def test_delegate_val
    Cubic.provider = test_provider

    Cubic.val("metric", 20)
    Cubic.val("metric", 30)
    Cubic.val("metric", 0)

    assert_equal [
      [:val, ["metric", 20]],
      [:val, ["metric", 30]],
      [:val, ["metric", 0]],
    ], test_provider.calls
  end

  def test_delegate_time
    Cubic.provider = test_provider

    Cubic.time("metric") { 50.times { raise "error" rescue nil } }
    calls = test_provider.calls

    assert_equal 1, calls.size
    time_call = calls.first
    name = time_call.first
    args = time_call.last

    assert_equal :time, name
    assert_equal "metric", args.first
  end

  def test_delegate_transaction
    Cubic.provider = test_provider

    Cubic.transaction do
      Cubic.val("metric", 20)
    end

    assert_equal [
      [:transaction, []]
    ], test_provider.calls
  end

end
