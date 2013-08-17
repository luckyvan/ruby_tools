#!/usr/bin/env ruby
# coding: UTF-8
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

# default parameters
params = {
	"from" => "/mnt/Development/Games/Games-001RG2",
	"to"   => "/mnt/Development/Games/Games-001RN5", 
	"ext" => [".sound", ".tga", ".movie"]
}


ARGV.each do |param|
	key, value = param.split ("=")
	if params.has_key? (key) and value
		params[key] = value
	end
end

p "Parameters are:"
p params

from = params["from"]
to   = params["to"]
extnames = params["ext"]

#check input parameters
fail "Invalid from path " + from unless File.directory?(from)
fail "Invalid to path " + to unless File.directory?(to)

#retrieve files satisfying the extension requirement
require 'pathname'
resource_files = Pathname.glob("#{from}/**/**").select do |path| 
	path.file? and extnames.include?(path.extname)
end

output = ["#!/usr/bin/env bash"]
resource_files.each do|path| 
	new_dir = path.dirname.sub(from, to)
	new_path = path.sub(from, to)
	if not new_dir.exist? 
		output << "mkdir -p #{new_dir}"
	end
	output << "cp #{path} #{new_path}"
end

File.open("merge.sh","w") do |file|
	output.each {|line| file.puts (line)}	
end

File.chmod(0755, "merge.sh")


puts output.uniq




