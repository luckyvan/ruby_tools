#!/usr/bin/ruby -w
# coding: UTF-8

require "ssh"

class RemoteHost
	def initialize(url, user = root)
		@shell = SSH.start(url, user).shell.sync
	end

	def last_logins
		logins = []
		@shell.send_command("last").stdout.each do |line|
			line.chomp!
			fields = [ line[0,8], line[10,8], line[19,15], line[36..-1]]
			next if files.include?(nil)
			logins << fields.map{ |f| f.strip }
		end
		logins
	end
end
