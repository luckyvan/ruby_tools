#!/usr/bin/ruby -w
# coding: UTF-8
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'traverse'
require 'av_manager'

path = ARGV[0]
fail "Invalid Input Path " + path unless File.directory?(path)

r = FileUtilsExt.ls_r(path) do |p|
	result = nil
	if File.file?(p)
	   if AvManager.removable?(p)
		   #report removable files
			result = p
	   else
		   #mv valid files to base directory
		   FileUtilsExt.mv_d(p, path)
	   end
	end
	result
end

p r[:files]
r[:files].each{|f| FileUtils.rm f}

