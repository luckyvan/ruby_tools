#!/usr/bin/env ruby
# coding: UTF-8
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'pathname'
require 'fileutils'

#input
source_path = Pathname.new(ARGV[0])
source_path = File.absolute_path(source_path)

fail "Invalid path: #{source_path}" unless File.exist?(source_path)

ru_path = Pathname.new("RequiredUpdates")
projects_path = Pathname.new("/mnt/Development/projects")

game_id = source_path.to_s[/Game-[\dA-Z]*/]

fail "no valid game_id" unless game_id

sub_path = source_path.sub(/^.*?#{game_id}\//, "")

des_path = projects_path + game_id + ru_path + sub_path

FileUtils.mkdir_p des_path.dirname
FileUtils.cp source_path, des_path




