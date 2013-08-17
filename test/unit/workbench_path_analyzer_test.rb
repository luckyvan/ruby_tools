#!/usr/bin/env ruby
require File.expand_path('../../test_helper', __FILE__) 
require 'workbench_path_analyzer'

class TestStartWorkbench < Test::Unit::TestCase
	must "simply match directory like '/wrs/WindRiver/VxWorks69-wrd50dm50a'" do
		assert_equal true, WorkbenchPathAnalyzer.valid?("VxWorks69-wrd50dm50a")	
	end
	 
	must "can not match platform implementation only for combo storage" do
		assert_equal false, WorkbenchPathAnalyzer.valid?("WindRiver42")
	end

	must "can not separate invalid path" do
		assert_equal [], WorkbenchPathAnalyzer.separate_path("WindRiver42")
	end

	must "separate valid windriver platform path by [platform with version, release version, build version]"do
		assert_equal ["wrlinux-42", "wrd50", "dm50a"], WorkbenchPathAnalyzer.separate_path("WindRiver42-wrd50dm50A")
	end

	must "separate valid cert platform path by [platform with version, release version, build version]"do
		assert_equal ["vxworks-cert-663", "wrd50", "dm50"], WorkbenchPathAnalyzer.separate_path("VxWorksCert663-wrd50dm50")
	end

	must "generate desired commands" do
		assert_equal "./startWorkbench.sh -configuration /pek-dsm-syrinx1/cfan/workspace/wrlinux-43/wrd50/dm50a/configuration", WorkbenchPathAnalyzer.generate_command("/wrs/WindRiver/WindRiver43-wrd50dm50A", "pek-dsm-syrinx", "cfan")
	end
end
