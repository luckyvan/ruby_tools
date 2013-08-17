#!/usr/bin/ruby -w
# coding: UTF-8
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require "socket"

TCPSocket.open("www.theonion.com", 80) do |socket|
	socket.puts "GET /	HTTP/1.0\n\n"
	puts socket.read
end
