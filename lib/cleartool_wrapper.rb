#!/usr/bin/env ruby
# coding: UTF-8
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

module CleartoolWrapper
	require 'wrapper'
	include Wrapper
	self.tool='/opt/rational/clearcase/bin/cleartool'
	class << self
		def ls_r(exp=nil,*args)
			files=lscheckout('-r', '/vobs/dsm_plugins/plugins/gemini')
			valid_files = files.to_s.split(/\n/).collect{|msg| getFileName(msg)}.select do|fn| 
				if(exp)
					fn =~ /#{exp}/
				else
					fn
				end
			end
			valid_files.uniq!
			valid_files.each{|file| p file}
		end
			

		def getFileName(msg)
			msg[/\"(.*)\"/,1]
		end
	end
end
