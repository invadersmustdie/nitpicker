#!/usr/bin/env ruby

require "nitpicker/runner"

class Readlog < NitPicker::Runner
  def run
    loop do
      # do something

      sleep 10
    end
  end

  def send_result
    @sender.send "readlog.#{@config[:source].split('/').join('.')} #{rand(1000)} #{Time.now.to_i}"
  end
end
