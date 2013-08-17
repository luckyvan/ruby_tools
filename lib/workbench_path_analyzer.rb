#!/usr/bin/env ruby

module WorkbenchPathAnalyzer
	class << self
		def valid?(path)
			return 	path =~ /(WindRiver|VxWorks(Cert)?)\d+-wrd\d+dm\d+/ ? true: false
		end
		
		def separate_path(path)
			entries = []
			if valid?(path)
				array = path.split(/(\d+)/) #[platform, p_version, -wrd, r_version, dm, b_version, (optional)sub_version]
				pf = array[0]
				case pf
				when 'WindRiver'
					platform = 'wrlinux'
				when 'VxWorksCert'
					platform = 'vxworks-cert'
				when 'VxWorks'
					platform = 'vxworks'
				end
				platform_with_version = platform + "-" + array[1]
				release_with_version = "wrd" + array[3]
				build_with_version = "dm" + array[5]	
				build_with_version += array[6] ? array[6].downcase : ''
				entries << platform_with_version
				entries << release_with_version
				entries << build_with_version
			end
			entries
		end
		
		def generate_command(dir, h_n, u_n)
		
			paths = dir.split('/')
			platform_path = paths[-1]
			separated_paths = separate_path(platform_path)
			fail "can not get platform paths by" + dir if separated_paths.empty?
		
			require 'pathname'
			config_path = Pathname.new('/')
			config_path += h_n.downcase + "1"
			config_path += u_n
			config_path += "workspace"
			separated_paths.each{|p| config_path += p}
			config_path += "configuration"
		
			"./startWorkbench.sh -configuration " + config_path.to_s
		end
	end
end
