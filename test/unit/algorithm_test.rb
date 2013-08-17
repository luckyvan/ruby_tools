#!/usr/bin/env ruby
# coding: UTF-8

require File.expand_path('../../test_helper',__FILE__)
require 'algorithm'


class TestAlgorithm < Test::Unit::TestCase
	must 'partition separate an array by a block' do
		a = [1,2,3,4,9,6,7,8,5]
		Algorithms::Sort.partition(a)
	end
end
