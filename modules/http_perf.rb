#!/usr/bin/env ruby

require "nitpicker/runner"

class HttpPerf < NitPicker::Runner
  def self.after_fork
    require "uri"
  end

  def get_ttfb(uri)
    socket = TCPSocket.new(uri.host, uri.port)

    request = [
      "GET #{uri.path} HTTP/1.1",
      "Host: #{uri.host}",
      "\r\n"
    ]

    ttfb = nil

    t0 = Time.now
    socket.write(request.join("\r\n"))

    socket.getc
    ttfb = Time.now - t0

    socket.close

    ttfb
  end

  def run
    # no nothing
    loop {}
  end

  def send_result
    ttfb = get_ttfb(URI.parse(@config[:uri]))

    @sender.send "http_perf.foo #{ttfb} #{Time.now.to_i}"
  end
end
