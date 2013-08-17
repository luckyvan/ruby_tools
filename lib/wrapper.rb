#!/usr/bin/ruby -w

module Wrapper
	def self.included(base)
		base.extend ClassMethods
	end

	module ClassMethods
		# include module will set its own tool
		attr_accessor :tool
		def method_missing(id, *args, &block)
			cmds=__getCmd__(id, *args)

			case cmds 
			when String
				exe(cmds)
			when Array
				cmds.each{|cmd| exe(cmd)}
			end
		end
		
		
		def __getCmd__(id, *args)
			case id
			when /_\w+/
				ids=id.to_s.split('_')
				return ids.map{|sub_id| regroup(sub_id, args)} 
			end
			regroup(id, *args)
		end

		def exe(cmd)
			r=`#{tool} #{cmd}`
		#	print r
			r
		end	

		private 
		def regroup(id, *args)
		    return ([id]+args).join(' ')
		end	
	end
end
