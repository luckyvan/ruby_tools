#!/usr/bin/ruby -w
# coding: UTF-8
#
#

def separate(a, s, e, &b)
	while(b.call(a[s]) && s<e) do
		s = s+1
	end
	while(!b.call(a[e]) && s<e) do
		e = e-1
	end
	
	if(s < e) then 
		temp = a[s]
		a[s] = a[e]
		a[e] = temp
	   separate(a, s+1, e-1, &b)	
	end
end

array = [1,2,3,4,5,6,7,8,9]

separate(array, 0, 8, Proc.new{|x| x%2 == 0})
