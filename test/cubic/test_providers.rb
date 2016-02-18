require "setup"

class TestProviders < Minitest::Test
  def setup
    Cubic.config do |c|
      c.provider = :memory
      c.provider_options = { email: "roomorama@example.org", api_key: "12345", source: "test" }
    end
  end

  def teardown
    Cubic.configuration = nil
  end

  def provider(name)
    Cubic.configuration.provider = name
  end

  def test_build_null
    provider :null
    assert_instance_of Cubic::Providers::Null, Cubic::Providers.build(Cubic.configuration)
  end

  def test_build_memory
    provider :memory
    assert_instance_of Cubic::Providers::Memory, Cubic::Providers.build(Cubic.configuration)
  end

  def test_build_librato
    provider :librato
    assert_instance_of Cubic::Providers::Librato, Cubic::Providers.build(Cubic.configuration)
  end
end
