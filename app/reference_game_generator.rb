#!/usr/bin/env ruby
# coding: UTF-8
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'checker'
require 'paytable_scanner'
require 'paytable_tokenizer'
require 'igt_env'
require 'game_factory'
require 'fileutils'

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

# 1. parse paytable and validate other inputs
Checker.check_file(params[:paytable])
Checker.check_nil(params[:gid], "game id as 'gid'")
Checker.check_nil(params[:rgid], "refernce game id as 'rgid'")

tokenizer = PaytableTokenizer.new()
tokenizer.parse(File.open(params[:paytable]).read)
scanner = PaytableScanner.new()
scanner.parse(tokenizer.tokens)

params[:root]        = IGTEnv.root
params[:game_output] = Pathname.new("./Gen/Development/Games/Game-00#{params[:gid]}")
params[:game_base]   = params[:game_output] + 'Resources/Generic/Base'
params[:proj_output] = Pathname.new("./Gen/Development/projects/Game-00#{params[:gid]}")

# 2. generate new game based on given game id
game_scripts = GameFactory.new_game params
puts "begin generate new game"

fail "fail to generate new game with id #{game_id}" unless system("sh -x ./#{game_scripts}")

# 3. merge resources
if params[:resources] then
  merge_script = GameFactory.merge params
  puts "begin merge resources"
  fail "fail to merge" unless system("sh -x ./#{merge_script}")
end

# 4. generate symbols related scripts
puts "begin generate symbols scripts"
GameFactory.generate_symbol_scripts scanner, params

# 5. generate configuration files
puts "begin generate config scripts"
GameFactory.generate_config_scripts scanner, params

# 6. generate rmlp if required
if scanner.rmlp then
  puts "begin add rmlp"
  GameFactory.generate_rmlp params
end

puts "Done"

