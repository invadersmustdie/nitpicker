require "nitpicker/graphite_sender"
require "daemons"

module NitPicker
  class Master
    attr_reader :master_pid, :runner_pid_map

    def initialize(config)
      @config = config
      @master_pid = Process.pid
      @runner_pid_map = {}

    end

    def install_sighandlers
      trap("SIGCHLD") do
        lost_child = Process.waitpid
        info = @runner_pid_map[lost_child]

        if info
          @config.logger.info "CHILD TERMINATED #{lost_child} (#{@runner_pid_map[lost_child][:name]})"

          @config.logger.info "RESTARTING #{lost_child} (#{info.inspect})"

          fork_collector(info[:name], info[:opts])
          @runner_pid_map.delete(lost_child)
        else
          @config.logger.info "PID #{lost_child} not known to Master"
        end
      end

      trap("SIGKILL") do
        @config.logger.info "[#{Process.pid}] MASTER received SIGKILL"
        exit 0
      end

      trap("SIGTERM") do
        @config.logger.info "[#{Process.pid}] MASTER received SIGTERM"

        @runner_pid_map.each do |pid, info|
          @config.logger.info "[#{Process.pid}] TERMINATING CHILD PROCESS #{pid} #{info[:name]}"
          Process.kill("SIGTERM", pid)
        end

        exit 0
      end
    end

    def start_runners
      @config.logger.info "MASTER_ID = #{master_pid}"

      @config.collectors.each do |cname, copts|
        fork_collector(cname, copts)
      end

      @config.logger.debug "[#{Process.pid}] MASTER (CHILDREN = #{@runner_pid_map.inspect})"
    end

    def fork_collector(name, opts)
      child = fork do
        @config.logger.info "[#{Process.pid}] starting fork for #{name}"
        @config.logger.info "[#{Process.pid}] CHILD (#{name})"

        opts.type.after_fork

        mod = opts.type.new(@config.sender, @config.logger)
        mod.configure(opts.config)

        mod.run
      end

      @config.logger.info "[#{Process.pid}] child pid #{child}"
      @runner_pid_map[child] = {:name => name, :opts => opts}
    end

    def start_runner_loop
      loop do
        sleep @config.interval

        @runner_pid_map.each do |pid, collector|
          @config.logger.debug "[#{Process.pid}] sending SIGUSR1 to #{pid} / #{collector[:name]}"
          Process.kill("SIGUSR1", pid)
        end
      end
    end

    def self.start(config)
      config.logger.info "[#{Process.pid}] daemonizing"

      Daemons.daemonize

      File.open(config.pidfile, "w+") do |fp|
        fp.puts Process.pid
      end

      config.reset_logger!

      $0 = "nitpicker (master)"

      master = Master.new(config)
      master.start_runners

      config.logger.debug "[#{Process.pid}] master_pid = #{master.master_pid}"

      if Process.pid == master.master_pid

        master.install_sighandlers
        master.start_runner_loop
      end
    end
  end
end
