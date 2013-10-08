#!/usr/bin/env ruby
# coding: UTF-8
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'checker'
require 'paytable_scanner'
require 'paytable_tokenizer'
require 'igt_env'
require 'game_factory'

fail "no inputs file #{ARGV[0]}" unless ARGV[0]

Checker.check_file(ARGV[0])

params = {}
File.open(ARGV[0], 'r').each_line do |line|
  if line.include?('=') then
    name = line.split(/=/)[0].strip.intern
    param = line.split(/=/)[1].strip
    param = param.split(/\s*,\s*/) if param.include?(',')
    params[name]=param
  end
end

require 'pp'
pp params

# 1. parse paytable and validate other inputs


Checker.check_file(params[:paytable])
Checker.check_nil(params[:gid], "game id as 'gid'")
Checker.check_nil(params[:rgid], "refernce game id as 'rgid'")

tokenizer = PaytableTokenizer.new()
tokenizer.parse(File.open(params[:paytable]).read)
scanner = PaytableScanner.new()
scanner.parse(tokenizer.tokens)

root    = IGTEnv.root
game_id = params[:gid]
game_output = "./Gen/Development/Games/Game-00#{game_id}"
rgame_id = params[:rgid]
resources = params[:resources]


# 2. generate new game based on given game id
# game_scripts = GameFactory.new_game game_id, rgame_id, root
# puts "begin generate new game from #{rgame_id} by #{game_id}, in #{root}"
# puts game_scripts

# fail "fail to generate new game with id #{game_id}" unless system("sh -x ./#{game_scripts}")

# 3. merge resources
# if resources then
  # merge_script = GameFactory.merge :from => resources, :to => game_output
  # puts "begin merge resources from #{resources} to #{game_output}, in #{root}"
  # fail "fail to merge" unless system("sh -x ./#{merge_script}")
# end

# 4. generate symbols related scripts
# GameFactory.generate_symbol_scripts scanner, :output => game_output, :game_id => game_id

# 5. generate configuration files
GameFactory.generate_config_scripts scanner, params

# # 6. generate rmlp if required
# if scanner.rmlp? then
  # GameFactory.generate_rmlp_scripts game_output
# end

