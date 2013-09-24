#!/usr/bin/env ruby
# coding: UTF-8
$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'


require 'fileutils'

file_dir = File.expand_path(File.dirname(__FILE__))
bin_dir =  file_dir + '/bin/'
back_dir =  file_dir + '/back/'

softlinks = {
  "create_file.rb" => "ct_f",
  "merge.rb" => "merge",
  "new_game.rb" => "ng",
  "symbols.rb" => "symbols",
}


softlinks.each_value do |bin|
  FileUtils.rm_f(bin_dir + '/' + bin)
end

FileUtils.rm_rf back_dir
