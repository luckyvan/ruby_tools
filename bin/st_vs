#!/usr/bin/env ruby

#kill existing process id
existing_pid=`ps aux| grep #{ENV['USER']} | grep Xvnc | grep -v grep`[/\d+/]
p `kill -9 #{existing_pid}` if existing_pid

Kernel.sleep 1
#remove tmp
port = 4
ARGV.each {|p| port = p[/\d+/] if p =~ /:\d+/}
tmp_file="/tmp/.X11-unix/X#{port}"
tmp_lock="/tmp/.X#{port}-lock"
`rm -f #{tmp_file}` if File.socket? tmp_file
`rm -f #{tmp_lock}` if File.file? tmp_lock

Kernel.sleep 1

#start vncserver
p `vncserver #{ARGV.join(' ')}`
