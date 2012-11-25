require "socket"

module NitPicker
  class GraphiteSender
    AVAILABLE_TYPES = [:udp, :tcp]
    FALLBACK_TYPE = :tcp

    attr_accessor :logger

    def initialize(host, port, type = FALLBACK_TYPE)
      @host = host
      @port = port
      @type = type

      if !AVAILABLE_TYPES.include?(@type)
        @type = FALLBACK_TYPE
      end

      @logger = Logger.new(nil)
    end

    def send(msg)
      @logger.debug "[#{Process.pid}] sending #{msg.inspect} (type = #{@type})"

      case @type
        when :udp then udp_send(msg)
        when :tcp then tcp_send(msg)
      end
    end

    def tcp_send(msg)
      @socket ||= TCPSocket.new(@host, @port)
      @socket.write("tcp." + msg + "\n")
    end

    def udp_send(msg)
      socket = UDPSocket.new
      socket.send("udp.#{msg} \n", 0, @host, @port)
    end
  end
end
