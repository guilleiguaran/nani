testdir = File.dirname(__FILE__)
$LOAD_PATH.unshift testdir unless $LOAD_PATH.include?(testdir)

libdir = File.dirname(File.dirname(__FILE__)) + '/lib'
$LOAD_PATH.unshift libdir unless $LOAD_PATH.include?(libdir)

require "rubygems"
require "nani"
require "minitest/unit"
require "minitest/autorun"

class Job
  attr_accessor :name

  def initialize(name = "Job1")
    @name = name
  end

  def run
    name
  end
end
