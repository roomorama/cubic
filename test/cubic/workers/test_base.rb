require "setup"
require "cubic/workers/base"

class TestBaseWorker < Minitest::Test
  def setup
    @worker = Cubic::Workers::Base.new
  end

  def test_rehearal
    result = nil
    @worker.rehearsal do
      result = 1
    end

    assert_equal 1, result
  end

  def test_log_error
    out, _ = capture_subprocess_io do
      @worker.log_error "logmsg_err"
    end
    assert_match "logmsg_err", out
  end

  def test_log_info
    out, _ = capture_subprocess_io do
      @worker.log_info "logmsg_info"
    end
    assert_match "logmsg_info", out
  end

  def test_shutdown
    assert_equal nil, @worker.shutdown?
  end

  def test_shutdown_after_call_shutdown
    @worker.shutdown!
    assert_equal true, @worker.shutdown?
  end
end
