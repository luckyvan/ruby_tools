#!/usr/bin/env ruby
# coding: UTF-8

require File.expand_path('../../test_helper',__FILE__)
require 'vlm_wrapper'


class TestVlmWrapper < Test::Unit::TestCase
	must "return unrecognized method as it is" do
		assert_equal "getAttr -t 18645 all", VlmWrapper.__getCmd__('getAttr', '-t', '18645','all')
	end

	must "return a group of method when input method name group by '_'" do
		assert_equal( 
			["reserve -t 18645",
			"turnOff -t 18645",
			"turnOn -t 18645",
			"restart -t 18645"], VlmWrapper.__getCmd__('reserve_turnOff_turnOn_restart','-t', '18645'))

	end

	must "has helper function to unreserve all boards reserved by me" do

	end
end
