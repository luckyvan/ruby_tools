#!/usr/bin/ruby -w
# coding: UTF-8
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require "fileutils"
require "tempfile"

class File
	def File.open_safely(path)
		result, temp_path = nil, nil
		Tempfile.open("#{$0}-#{path.hash}") do |f|
			result = yield f
			temp_path = f.path
		end
		FileUtils.move(temp_path, path)
		result
	end
end
