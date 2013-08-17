#!/usr/bin/env ruby
# coding: UTF-8
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'vlm_wrapper'


VlmWrapper.__send__(*ARGV)


