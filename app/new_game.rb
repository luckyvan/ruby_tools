#!/usr/bin/env ruby
# coding: UTF-8
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

# default parameters
defaults = {
	"from" => "1RG2",
	"to"   => "1RN5",
	"root" => Dir.exist?("/cygdrive/") ? "/cygdrive/d/Development" : "/mnt/Development",
}



input_params = {}
ARGV.each do |param|
	key, value = param.split ("=")
	input_params[key] = value
end

input_params = defaults.merge(input_params)
p "Input Params => "
p input_params

require 'erb'
template_file = File.open(File.dirname(File.realdirpath(__FILE__)) + "/new_game/new_game.template.sh").read() 
erb = ERB.new(template_file)
new_sh = erb.result( binding )

file_name = "ng.sh"
print "Creating #{file_name}\n"
File.open(file_name, "w").write( new_sh )


