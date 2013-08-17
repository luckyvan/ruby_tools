#!/usr/bin/ruby -w

$LOAD_PATH.unshift File.dirname(__FILE__) 

module VlmWrapper
	require 'wrapper'
	include Wrapper
	self.tool='/folk/vlm/commandline/vlmTool'

	class << self
		def unreserveAll()
			boards = findMine().split(/\s/)
			boards.each{|b| unreserve('-t', b)}
			nil
		end
		
		def tel(bc)
			ip=getAttr('-t',bc,'terminalserver').chomp
			port=(getAttr('-t',bc,'port').to_i + 2000).to_s
			print "telnet #{ip} #{port}\n"
		end
	end
end
