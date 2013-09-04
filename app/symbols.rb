#!/usr/bin/env ruby
# coding: UTF-8
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require 'erb'

# default parameters
params = {
  "root" => Dir.exist?("/cygdrive/") ? "/cygdrive/d/Development" : "/mnt/Development",
  "wild" => "WW",
  "other_symbols" => ["M1","M2","M3","M4","F5","F6","F7","F8","D1"],
  "scatter"   => "B1",
  "bonus"   => "B1",
  "game_id" => "1DR3",
  "output" => "./GenerateSymbolScripts",
  "custom_symbol_functions" => {
    :name => "CustomSymbolFunctions.lua",
    :dir => "Configuration/Game.Main/Scripts/Symbols/",
  },
  "symbol_variables" => {
    :name => "SymbolVariables.lua",
    :dirs => [
      "Configuration/Game.Main/Scripts/Presentation",
      "Configuration/Game.FreeSpinBonus/Scripts/Presentation",
    ]
  },
  "others" => {
    "BaseGameSymbolImageTranslations.lua" => "Game.DynamicGameRules/Scripts/Translations",
    "FreeSpinSymbolImageTranslations.lua" => "Game.DynamicGameRules/Scripts/Translations",
    "DynamicActorTextureList.lua" => "Game.DynamicGameRulesBuilder/Scripts/Presentation",
    "SymbolInfoValuesTable.lua" => "Game.Main/Scripts/SymbolInfo",
    "SymbolInfoImageTranslations.lua" => "Game.Main/Scripts/Translations",
    "SymbolInfoTableTranslations.lua" => "Game.Main/Scripts/Translations",
  }
}

puts params
root    = params["root"]
game_id = params["game_id"]
game_root = "#{root}/Games-00#{game_id}/Resources/Generic/Base",
wild    = params["wild"]
scatter = params["scatter"]
bonus   = params["bonus"]
symbols = params["other_symbols"] << wild << scatter << bonus
symbols = symbols.uniq
others  = params["others"]
gaffs   = {
  :name = "Game-00#{game_id}.Show.script",
  :dir  = "System.Show/Scripts"
}
template_dir = File.dirname(__FILE__) + '/../app/symbols/templates'

#tf = File.open(template_dir + '/SymbolInfoValuesTable').read
#puts ERB.new(tf).result(binding)

#custome symbol funcitons
csf = File.open(template_dir + '/CustomSymbolFunctions').read
#puts csf.gsub("SC", scatter)

#gaffs
#gaff = File.open(template_dir + '/Gaffs').read

#symbol variables
