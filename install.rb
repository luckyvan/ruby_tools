#!/usr/bin/env ruby
# coding: UTF-8
$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'

require 'fileutils'

file_dir = File.expand_path(File.dirname(__FILE__))
bin_dir =  file_dir + '/bin/'

# add bin to env
File.open(File.expand_path("~/.bashrc"), "a"){ |f| f.puts "PATH=#{bin_dir}:\$PATH" }

# back up all bin/* files
back_dir = file_dir + "/back/"
FileUtils.rm_r back_dir if Dir.exist?(back_dir)
FileUtils.mkdir_p(back_dir) unless Dir.exist?(back_dir)
FileUtils.cp_r bin_dir, back_dir

# create soft links supportted now.
app_dir = file_dir + '/app/'
softlinks = {
  "create_file.rb" => "ct_f",
  "merge.rb" => "merge",
  "new_game.rb" => "ng",
  "symbols.rb" => "symbols",
}

Dir.glob(app_dir + '*').each do |f|
  file_name = File.basename f
  FileUtils.ln_s(f, bin_dir + '/' + softlinks[file_name], :force => true) if softlinks[file_name]
end
