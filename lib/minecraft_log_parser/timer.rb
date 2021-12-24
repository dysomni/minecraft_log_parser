# frozen_string_literal: true

module MinecraftLogParser
  # wrapper for timing functionality while parsing
  class Timer
    class << self
      attr_accessor :timer

      def time(&block)
        timer.call(block)
      end
    end
  end
end

begin
  exists = begin
    Monotime::Duration
  rescue StandardError
    nil
  end
  require "monotime" unless exists
  MinecraftLogParser::Timer.timer = ->(to_time) { Monotime::Duration.with_measure(&to_time) }
rescue LoadError
  puts "unable to load monotime, include this in your gemfile to track timing of minecraft_log_parser's speed"
  MinecraftLogParser::Timer.timer = ->(to_time) { return to_time.call, nil }
end
