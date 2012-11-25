require "modules/readlog"
require "modules/http_perf"

NitPicker::Config.set do |cfg|
  # describe interval in which the metrics should be sent to the graphite server
  cfg.interval = 5

  # setup logfile
  cfg.logfile = "/tmp/nitpicker.log"

  # setup pidfile
  cfg.pidfile = "/tmp/nitpicker.pid"

  # setup graphite server
  cfg.graphite_server = ["33.33.33.34", 2003, :udp]

  # a collector consists of the following properties
  #  - name  (eg "/var/log/message") which must be uniq
  #  - type  reference to the executing class
  #  - configuration  hashset that contains all configuration necessary
  cfg.add_collector("/var/log/message") do |c|
    c.type = Readlog
    c.configure :source => "var/log/messages"
  end

  cfg.add_collector("/var/log/nginx") do |c|
    c.type = Readlog
    c.configure :source => "var/log/nginx"
  end

  cfg.add_collector("rugek.dirtyhack.net") do |c|
    c.type = HttpPerf
    c.configure :uri => "http://rugek.dirtyhack.net"
  end
end
