#!/usr/bin/env ruby
# coding: UTF-8
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

module Checker
  class << self
    def check_file(path)
      raise "Invalid file: #{path}" unless File.file?(path)
    end

    def check_dir(path)
      raise "Invalid dir: #{path}" unless File.directory?(path)
    end

    def check_nil(obj, error_msg)
      raise "Nil vlaue for #{error_msg}" unless obj
    end

    def symbol_resource_exist?(symbol, resources)
      resources.each do |r|
        return true if r.to_s.match(symbol)
      end
      false
    end
  end
end
