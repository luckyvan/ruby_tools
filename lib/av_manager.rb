#!/usr/bin/ruby -w
# coding: utf-8
# the manager would perform following task
# 1. collecting files which should be removed
# 2. deleting empty directories

$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'traverse'

module AvManager
	VALID_EXTENSIONS = ['rm','mkv','jpeg','wmv','jpg','JPG','mpg', 'mp4', 'avi', 'rmvb',  'rmb',  'torrent', 'ass', 'PNG', 'BMP']
	INVALID_BASENAME = ['SIS001全面封殺', 'Sky.jpg', 'SIS真相', '感謝下載','AV9.CC-最低價點數大放送','第一会所 宣传图']
	def self.invalid_extension?(f)
		VALID_EXTENSIONS.each do |e| 
			return false if f.end_with?(e)
		end
		true
	end

	def self.invalid_basename?(f)
		INVALID_BASENAME.each do |b|
			return true if (File.basename(f) =~ Regexp.new(b))
		end
		false
	end

	def self.removable?(f)
		invalid_extension?(f) || invalid_basename?(f)
	end

	def self.get_removable_files(d)
		r = FileUtilsExt.ls_r(d) do |f|
			result = nil
			if File.file?(f)
				result = f if AvManager.removable?(f)
			end
			result
		end
		r[:files]
	end

end

