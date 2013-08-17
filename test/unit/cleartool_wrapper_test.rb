#!/usr/bin/env ruby
# coding: UTF-8

require File.expand_path('../../test_helper',__FILE__)
require 'cleartool_wrapper'


class TestCleartoolWrapper < Test::Unit::TestCase
	must "analyze the correct file from lscheckout return" do
		assert_equal "./wrmsenv/src/java/com/windriver/dsm/tools/environment/wrenv/vxworks/VxWorksPlatformSetup.java",	CleartoolWrapper.getFileName("--09-21T09:58  cfan       checkout version \"./wrmsenv/src/java/com/windriver/dsm/tools/environment/wrenv/vxworks/VxWorksPlatformSetup.java\" from /main/dsm_iter11-dev.pk/2 ")
	end
end
