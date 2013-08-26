#!/usr/bin/env ruby

fs = Dir['/wrs/WindRiver/*/install.properties']
fs.each do |f|
	File.open(f) do |io|
		platform=nil
		label=nil
		io.each_line do |line|
			if line =~ /\.type=platform/
				platform=line.split('.')[0] unless line =~ /standalone/
			end
			if platform
				if line =~ /#{platform}.label/ 
					label=line.split('=')[1] 
				end
			end
		end
		p platform
		p label
	end
end
