#!/usr/bin/env ruby
# coding: UTF-8
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'cleartool_wrapper'


CleartoolWrapper.__send__(*ARGV)


