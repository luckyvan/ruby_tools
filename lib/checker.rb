#!/usr/bin/env ruby
# coding: UTF-8
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

module Checker
  def self.check_file(path)
    raise "Invalid file: #{path}" unless File.file?(path)
  end

  def self.check_nil(obj, error_msg)
    raise "Nil vlaue for #{error_msg}" unless obj
  end
end
