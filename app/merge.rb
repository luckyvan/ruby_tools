#!/usr/bin/env ruby
# coding: UTF-8
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

# default parameters
root = Dir.exist?("/cygdrive/") ? "/cygdrive/d/Development" : "/mnt/Development"
params = {
	"from" => ["#{root}/Games/Games-001RG2"],
	"to"   => "#{root}/Games/Games-001RN5",
	"ext" => [".sound", ".tga", ".movie"],
	"exclusion" => ["Messages.movie", "TransitionMessages.movie", "OverReelsMessages.movie", "MathBoxMessages.movie", "RetriggerMessages.movie"],
}



ARGV.each do |param|
	key, value = param.split ("=")
	if params.has_key? (key) and value then
		case key
		when "from","exclusion" then params[key] = value.split(",")
		when "to"   then params[key] = value
		when "ext"  then params[key] = value.split(",").map {|e| "."+e}
		end
	end
end

p "Parameters are:"
p params

from = params["from"]
to   = params["to"]
extnames = params["ext"]
exclusion = params["exclusion"]

#check input parameters
from.each do |p|
	fail "Invalid from path " + p unless File.directory?(p)
end
fail "Invalid to path " + to unless File.directory?(to)

#retrieve files satisfying the extension requirement
require 'pathname'

output = ["#!/usr/bin/env bash"]

from.each do |f|
	resource_files = Pathname.glob("#{f}/**/**").select do |path|
		path.file? and extnames.include?(path.extname)
	end

	resource_files.each do|path|
		if (not exclusion.include?(path.basename.to_s)) then
			new_dir = path.dirname.sub(f, to)
			new_path = path.sub(f, to)
			if not new_dir.exist?
				output << "mkdir -p #{new_dir}"
			end
			output << "cp #{path} #{new_path}"
		end
	end
end

output = output.uniq
File.open("merge.sh","w") do |file|
	output.each {|line| file.puts (line)}
end

File.chmod(0755, "merge.sh")




