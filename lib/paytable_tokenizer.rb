#!/usr/bin/env ruby
# coding: UTF-8
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

class PaytableTokenizer
  @delims = ['[', ']', '{', '}', '=']
  attr_accessor :tokens

  def initialize()
    @tokens = []
  end

  def parse (input)
    input.each_line do |line|
      #erase comment and spaces both front and back ends.
      line = line.gsub(/\/\/.*/, '').gsub(/^\s*/,'').gsub(/\s*$/,'')

      if('[' == line[0]) then
        raise "line #{line} does not end with ']' when begins with '['" unless line[-1] == ']'
        @tokens << '[' << line[1..-2] << ']'
      elsif('{' == line[0] or '}' == line[0]) then
        @tokens << line[0]
      elsif(line =~ /\s*=\s*/)
        @tokens << '='
        @tokens << line.gsub(/\s*=.*/, '')
        @tokens << line.gsub(/.*=\s*/, '')
      end
    end
  end
end
