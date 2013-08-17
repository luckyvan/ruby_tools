#!/usr/bin/env ruby 

pf2sb={
	"rb" => "#!/usr/bin/env ruby",
	"sh" => "#!/bin/bash",
	"" => ""
}

path = ARGV[0]
match = /(.*\.)(.*$)/.match(path) 
extension = if match.nil?
				""
			else
				match[2]
			end
fail "specify filename to create" unless path

def f_w(path, info)
	File.open(path, "w"){ |f| f.puts info }
end

def f_a(path, info)
	File.open(path, "a"){ |f| f.puts info }
end

#write shebang
f_w(path, pf2sb[extension])

#coding
f_a(path, "# coding: UTF-8")
#for ut
if path =~ /_test.rb$/
	module_name = File.basename(path).sub("_test.rb","")
	f_a(path, "")
	f_a(path, "require File.expand_path('../../test_helper',__FILE__)")	
	f_a(path, "require '"+module_name+"'")
	f_a(path, "")
	f_a(path, "")
	f_a(path, "class Test" + module_name.split('_').each{|w| w.capitalize!}.join + " < Test::Unit::TestCase")
	f_a(path, "end")
elsif path =~ /_wrapper.rb$/
	module_name = File.basename(path).sub("_wrapper.rb","")
	f_a(path, "$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'")
	f_a(path, "")
	f_a(path, "module " + module_name.split('_').each{|w| w.capitalize!}.join )
	f_a(path, "\t" + "require \'wrapper\'")
	f_a(path, "\t" + "include Wrapper")
	f_a(path, "    " + "self.tool=$$$$$$$$$")
	f_a(path, "")
	f_a(path, "\t" + "class << self")
	f_a(path, "\t" + "end")
	f_a(path, "end")
else
	f_a(path, "$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'")
end

File.chmod(0755, path)
system "vim", path
