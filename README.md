# NitPicker

NitPicker provides a managed environment for graphite collectors

## Requirements

ruby (>= 1.9.3)
daemons

## Installation

NOTE: this project is currently in experimental state, so there is no out of the box installation or setup

<pre>
git clone git@github.com:invadersmustdie/nitpicker.git`
cd nitpicker
./start.sh
</pre>

## Configuration

NitPicker profiled a simple DSL for setting up connectors

<pre>
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
</pre>

## Running

Start
<pre>
./start.sh
</pre>

Stop
<pre>
kill `cat /tmp/nitpicker.pid`
</pre>

## Basic architecture

* every collector becomes a child process of the master
* the master process has the control loop which sends SIGUSR1 to every child process when the interval time (cfg.interval) is lapsed
* if a child process dies the master will respawn it
* if master process receives SIGTERM it will shutdown all collectors and terminate the child processes
