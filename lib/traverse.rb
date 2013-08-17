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

	def self.shrink(f)
		f.gsub(/\/+/, '/').gsub(/\s+/,'')
	end

	def self.mv_d(file, dir)
		new_file = dir + '/' + file.split('/')[-1]

		require 'fileutils'
		if (shrink(file) == shrink(new_file))
		else
			FileUtils.mv(file, new_file) unless (shrink(file) == shrink(new_file))
		end

	end
	
end
