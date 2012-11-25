module NitPicker
  class Runner
    def self.after_fork
    end

    def initialize(sender, logger)
      @config = {}

      @sender = sender
      @logger = logger

      install_sighandler
      rename_process
    end

    def configure(config)
      @config = config
    end

    private

    def install_sighandler
      @logger.debug "[#{Process.pid}] installing signal handlers"

      trap("SIGUSR1") do
        send_result
      end

      @logger.debug "[#{Process.pid}] installed signal handlers"
    end

    def rename_process
      $0 = "nitpicker (collector) #{self.class}"
    end
  end
end
