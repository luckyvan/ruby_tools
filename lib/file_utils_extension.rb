#!/usr/bin/env ruby

module FileUtilsExt
	def self.ls_r(dir, &block)
		require 'pathname'
			fail "Invalid Directory Input" unless File.directory?(dir)
				result = Hash[:files,[],:dirs,[]]
				Dir.glob(Regexp.escape(dir)+'/''*').each do |d|	
					if File.directory?(d)
						r = ls_r(d, &block)
						result[:files] += r[:files]
						result[:dirs] += r[:dirs]
					end
					output_msg = (block_given?) ? (yield d) : d
					output_collection = (File.file?(d)) ? result[:files] : result[:dirs]
					output_collection << output_msg if output_msg
				end
			result
	end

end
