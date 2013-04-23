require "test_helper"

class QueueTest < MiniTest::Unit::TestCase
  def setup
    @queue ||= Nani::Queue.new("queue1")
  end

  def test_queue_name
    assert_equal @queue.name, "queue1"
  end

  def test_queue_push
    job = Job.new
    assert_instance_of Bunny::Queue, @queue.push(job)
  end

  def test_close_connection
    assert_nil @queue.close_connection
  end
end
