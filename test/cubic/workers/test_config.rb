require "setup"
require "cubic/workers/config"
require "byebug"

class TestConfig < Minitest::Test
  def setup
  end

  def test_config_with_block
    config_object = Cubic::Workers::Config.new do
      config.email = "webmaster@roomorama.com"
      config.api_key = "123"
    end

    config_object.load!

    assert_equal "webmaster@roomorama.com", config_object.config.email
    assert_equal "123", config_object.config.api_key
  end

  def test_config_with_path
    path = File.join(__dir__, "config.yml")
    config_object = Cubic::Workers::Config.new(path)

    config_object.load!
    assert_equal "123", config_object.config.api_key
    assert_equal "webmaster@roomorama.com", config_object.config.email
  end
end
