#!/usr/bin/env ruby
# coding: UTF-8
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

module IGTEnv
  def self.root
    root = Dir.exist?("/cygdrive/")?"/cygdrive/d/Development":"/mnt/Development"
    raise "not a valid pathname: #{root}" unless Dir.exist?(root)
    root
  end
end
