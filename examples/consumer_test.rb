$:.unshift(File.expand_path("../../lib", __FILE__))
require "nani"

class Job
  def initialize(name)
    @name = name
  end

  def run
    puts @name
  end
end

consumer = Nani::Consumer.new("jobs_queue", 2)
puts "Starting consumer with queue 'jobs_queue' and 2 workers"

consumer.start
Signal.trap('INT') { consumer.close_connection }
