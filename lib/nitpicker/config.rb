require "nitpicker/collector"
require "logger"

module NitPicker
  class Config
    attr_reader :collectors, :logfile
    attr_accessor :interval, :logger, :graphite_server, :pidfile

    def initialize
      @collectors = {}
      @logger = nil
      @logfile = "/tmp/nitpicker-fallback.log"
    end

    def add_collector(name, &block)
      c = Collector.new(name)
      yield(c) if block_given?

      @collectors[name] = c

      c
    end

    def logfile=(lf)
      @logger = Logger.new(lf)
      @logfile = lf
    end

    def reset_logger!
      @logger = Logger.new(@logfile)
    end

    def sender
      @sender ||= GraphiteSender.new(*@graphite_server)
      @sender.logger = @logger

      @sender
    end

    def self.set(&block)
      cfg = Config.new
      yield(cfg) if block_given?

      cfg
    end
  end
end
