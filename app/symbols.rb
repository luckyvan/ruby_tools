#!/usr/bin/env ruby
# coding: UTF-8
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require 'erb'
require 'pathname'
require 'fileutils'
# default parameters
params = {
  "root" => Dir.exist?("/cygdrive/") ? "/cygdrive/d/Development" : "/mnt/Development",
  "wild" => "WW",
  "other_symbols" => ["F5","F6","F7","F8","D1"],
  "scatter"   => "SC",
  "bonus"   => "SC",
  "game_id" => "1DR3",
  "output" => Pathname.new("./GenerateSymbolScripts"),
  "custom_symbol_functions" => {
    :name => "CustomSymbolFunctions.lua",
    :dir => Pathname.new("Configuration/Game.Main/Scripts/Symbols/"),
  },
  "symbol_variables" => [
    {
      :name => "SymbolVariables.lua",
      :dir => Pathname.new("Configuration/Game.Main/Scripts/Presentation"),
      :resource => "Game.Main/Images/Symbols",
    },
    {
      :name => "SymbolVariables.lua",
      :dir => Pathname.new("Configuration/Game.FreeSpinBonus/Scripts/Presentation"),
      :resource => "Game.FreeSpinBonus/Images/Symbols",
    },
  ],
  "others" => [
    {:name =>"BaseGameSymbolImageTranslations.lua", :path => Pathname.new("Game.DynamicGameRules/Scripts/Translations"),},
    {:name =>"FreeSpinSymbolImageTranslations.lua", :path => Pathname.new("Game.DynamicGameRules/Scripts/Translations"),},
    {:name =>"DynamicActorTextureList.lua", :path => Pathname.new("Game.DynamicGameRulesBuilder/Scripts/Presentation"),},
    {:name =>"SymbolInfoValuesTable.lua", :path => Pathname.new("Game.Main/Scripts/SymbolInfo"),},
    {:name =>"SymbolInfoImageTranslations.lua", :path => Pathname.new("Game.Main/Scripts/Translations"),},
    {:name =>"SymbolInfoTableTranslations.lua", :path => Pathname.new("Game.Main/Scripts/Translations"),},
  ]
}

# helper functions
def check_path(path)
  fail "Invalid path: #{path}" unless File.exist?(path)
end

def symbol_resource_exist?(symbol, resources)
  resources.each do |r|
    return true if r.to_s.match(symbol)
  end
  false
end

def collect_movies(symbol, movies, length)
  symbol_movies = movies.select{ |m| m.to_s.match(symbol) }

  while symbol_movies.length < length do
      symbol_movies << symbol_movies[-1]
  end
  symbol_movies
end

def write_file(file_path, file_name, contents)
  FileUtils.mkdir_p file_path
  File.open(file_path + file_name, "w").write contents
end

#input
ARGV.each do |param|
  key, value = param.split ("=")
  if params.has_key? (key) and value then
    case key
    when "other_symbols" then params[key] = value.split(",")
    when "wild","scatter", "bonus", "game_id"   then params[key] = value
    end
  end
end


#final params
root    = params["root"]
output  = params["output"]
game_id = params["game_id"]
game_root = Pathname.new("#{root.to_s}/Games/Game-00#{game_id}/Resources/Generic/Base")
wild    = params["wild"]
scatter = params["scatter"]
bonus   = params["bonus"]
other_symbols = params["other_symbols"]
symbols = Array.new(other_symbols) << wild << scatter << bonus
symbols = symbols.uniq
symbol_variables = params["symbol_variables"]
others  = params["others"]
custom_symbol_functions = params["custom_symbol_functions"]
gaffs   = {
  :name => "Game-00#{game_id}.Show.script",
  :dir  => Pathname.new("System.Show/Scripts"),
}
template_dir = Pathname.new(File.dirname(__FILE__) + '/../app/symbols/templates')

#check paths
check_path(root)
check_path(game_root)

#symbol variables
symbol_variables.each do |sv|
  resource_path = game_root + sv[:resource]
  check_path(resource_path)

  tgas = Pathname.glob( resource_path + "*.tga" ).map{|p| p.basename}
  movies = Pathname.glob( resource_path + "*.movie" ).map{|p| p.basename}

  symbols_without_tga = symbols.reject{ |s| symbol_resource_exist?(s, tgas) }
  fail "Invalid Symbols #{symbols_without_tga.to_s} without tga in path: #{resource_path.to_s}\n" unless symbols_without_tga.empty?

  bonus_movies = collect_movies(bonus, movies, 3)
  wild_movies = collect_movies(wild, movies, 3)

  normal_symbols = other_symbols.reject{|s| symbol_resource_exist?(s, movies)}
  movie_symbols  = other_symbols.select{|s| symbol_resource_exist?(s, movies)}.map{|s| {:name => s, :movies => collect_movies(s, movies, 2)}}
  symbol_varialbs_t = File.open(template_dir + "SymbolVariables").read
  erb = ERB.new(symbol_varialbs_t).result(binding)
  write_file output+sv[:dir], sv[:name], erb
end

others.each do |f|
  template = f[:name].sub(".lua","")
  tf = File.open(template_dir + "#{template}").read
  erb = ERB.new(tf).result(binding)
  write_file output+f[:path], f[:name], erb
end

#custome symbol funcitons
csf = File.open(template_dir + "CustomSymbolFunctions").read
write_file (output + custom_symbol_functions[:dir]), custom_symbol_functions[:name], csf.gsub("SC", scatter)

#gaffs
gaff = File.open(template_dir + "Gaffs").read
write_file (output + gaffs[:dir]), gaffs[:name], gaff.gsub("SC", scatter)

puts "Generate files into Dir #{output}"
