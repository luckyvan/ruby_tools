#!/usr/bin/env ruby
# coding: UTF-8
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'checker'
require 'paytable_scanner'
require 'paytable_tokenizer'
require 'igt_env'

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
Checker.check_nil(params[:gid], "game id")

tokenizer = PaytableTokenizer.new()
tokenizer.parse(File.open(params[:paytable]).read)
scanner = PaytableScanner.new()
scanner.parse(tokenizer.tokens)

symbols = scanner.base.symbols
root    = IGTEnv.root
game_id = params[:gid]


# 2. generate new game based on given game id

# 3. merge resources

# 4. generate symbols related scripts

# 5. generate configuration files

# 6. generate rmlp if required

