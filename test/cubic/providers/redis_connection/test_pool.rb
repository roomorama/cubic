require_relative "../../../setup"
require "cubic/providers/redis_connection/pool"

class TestPool < Minitest::Test
  def setup
    @url = "redis://localhost:9200"
  end

  def test_size
    pool = Cubic::Providers::RedisConnection::Pool.new(@url)
    assert_equal pool.size, 5
  end

  def test_get_object
    pool = Cubic::Providers::RedisConnection::Pool.new(@url)
    obj = pool.get_object
    assert_instance_of ::Redis, obj
  end

  def test_get_different_object
    pool = Cubic::Providers::RedisConnection::Pool.new(@url, 2)
    obj1 = pool.get_object
    obj2 = pool.get_object

    assert_operator obj1.object_id, :!=, obj2.object_id
  end

  def test_get_out_of_range
    pool = Cubic::Providers::RedisConnection::Pool.new(@url, 1)
    obj1 = pool.get_object

    assert_raises do
      obj2 = pool.get_object
    end
  end

  def test_release_object
    pool = Cubic::Providers::RedisConnection::Pool.new(@url, 1)
    obj1 = pool.get_object
    pool.release(obj1)

    obj2 = pool.get_object
    assert_equal obj1, obj2
  end
end
