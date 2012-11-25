#!/usr/bin/env ruby

`ps aux|grep nitpicker`.split("\n").map { |x| `kill -9 #{x.split(/\s+/)[1]}` }
