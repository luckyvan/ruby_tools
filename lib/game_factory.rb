#!/usr/bin/env ruby
# coding: UTF-8
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require 'checker'
require 'igt_env'
require 'pp'
require 'erb'
require 'fileutils'

module GameFactory
  class << self
    def new_game( gid, rgid, root )
      require 'erb'
      template_file = File.open(File.dirname(File.realdirpath(__FILE__)) + "/rg_gen/new_game/new_game.template.sh").read()
      erb = ERB.new(template_file)
      new_sh = erb.result( binding )

      file_name = "ng.sh"
      print "Creating #{file_name}\n"
      File.open(file_name, "w") do |f|
        f.write( new_sh )
      end
      return file_name
    end

    def merge(params)
      default = {:ext => [".sound", ".tga", ".movie"],
                 :exclusion => ["Messages.movie", "TransitionMessages.movie", "OverReelsMessages.movie", "MathBoxMessages.movie", "RetriggerMessages.movie"],}
      params = params.merge default
      from = params[:from]
      to = params[:to]
      extnames = params[:ext]
      exclusion = params[:exclusion]

      Checker.check_nil(to, "output")
      Checker.check_nil(from, "resources")
      Checker.check_nil(extnames, "resources extension")
      Checker.check_nil(exclusion, "resources not to be merged")
      from.each {|d| Checker.check_dir(d)}
      Checker.check_dir(to)

      output = ["#!/usr/bin/env bash -x"]

      from.each do |f|
        resource_files = Pathname.glob("#{f}/**/**").select do |path|
          path.file? and extnames.include?(path.extname)
        end

        resource_files.each do|path|
          if (not exclusion.include?(path.basename.to_s)) then
            new_dir = path.dirname.sub(f, to)
            new_path = path.sub(f, to)
            if not new_dir.exist?
              output << "mkdir -p #{new_dir}"
            end
            output << "cp #{path} #{new_path}"
          end
        end
      end

      output = output.uniq
      File.open("merge.sh","w") do |file|
        output.each {|line| file.puts (line)}
      end

      File.chmod(0755, "merge.sh")

      return "merge.sh"
    end

    def generate_symbol_scripts( scanner, params = {} )
      default = {
        :root => IGTEnv.root,
        :bonus   => "SC",
        :game_id => "1DR2",
        :custom_symbol_functions => {
          :name => "CustomSymbolFunctions.lua",
          :dir => Pathname.new("Configuration/Game.Main/Scripts/Symbols/"),
        },
        :symbol_variables => [
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
        :others => [
          {:name =>"BaseGameSymbolImageTranslations.lua", :path => Pathname.new("Game.DynamicGameRules/Scripts/Translations"),},
          {:name =>"FreeSpinSymbolImageTranslations.lua", :path => Pathname.new("Game.DynamicGameRules/Scripts/Translations"),},
          {:name =>"DynamicActorTextureList.lua", :path => Pathname.new("Game.DynamicGameRulesBuilder/Scripts/Presentation"),},
          {:name =>"SymbolInfoValuesTable.lua", :path => Pathname.new("Game.Main/Scripts/SymbolInfo"),},
          {:name =>"SymbolInfoImageTranslations.lua", :path => Pathname.new("Game.Main/Scripts/Translations"),},
          {:name =>"SymbolInfoTableTranslations.lua", :path => Pathname.new("Game.Main/Scripts/Translations"),},
        ]
      }

      params = default.merge(params)
      # final params
      root  = params[:root]
      output = Pathname.new(params[:output])
      game_id = params[:game_id]
      bonus = scanner.base.bonus_symbol
      scatter = bonus
      bonus_win = scanner.base.trigger_index
      symbols = scanner.base.symbols
      wild = symbols[0]
      other_symbols = symbols - [wild, bonus]
      symbol_variables = params[:symbol_variables]
      others  = params[:others]
      custom_symbol_functions = params[:custom_symbol_functions]
      game_root = Pathname.new("#{output}/Resources/Generic/Base")
      gaffs   = {
        :name => "Game-00#{game_id}.Show.script",
        :dir  => Pathname.new("System.Show/Scripts"),
      }
      template_dir = Pathname.new(File.dirname(__FILE__) + '/../lib/rg_gen/symbols/templates')

      #check paths
      Checker.check_dir(root)
      Checker.check_dir(game_root)
      p game_root
      #symbol variables
      symbol_variables.each do |sv|
        resource_path = game_root + sv[:resource]
        Checker.check_dir(resource_path)

        tgas = Pathname.glob( resource_path + "*.tga" ).map{|p| p.basename}
        movies = Pathname.glob( resource_path + "*.movie" ).map{|p| p.basename}

        symbols_without_tga = symbols.reject{ |s| Checker.symbol_resource_exist?(s, tgas) }
        fail "Invalid Symbols #{symbols_without_tga.to_s} without tga in path: #{resource_path.to_s}\n" unless symbols_without_tga.empty?

        bonus_movies = collect_movies(bonus, movies, 3)
        wild_movies = collect_movies(wild, movies, 3)

        normal_symbols = other_symbols.reject{|s| Checker.symbol_resource_exist?(s, movies)}
        movie_symbols  = other_symbols.select{|s| Checker.symbol_resource_exist?(s, movies)}.map{|s| {:name => s, :movies => collect_movies(s, movies, 2)}}
        symbol_varialbs_t = File.open(template_dir + "SymbolVariables").read
        erb = ERB.new(symbol_varialbs_t).result(binding)
        write_file game_root+sv[:dir], sv[:name], erb
      end

      others.each do |f|
        template = f[:name].sub(".lua","")
        tf = File.open(template_dir + "#{template}").read
        erb = ERB.new(tf).result(binding)
        write_file game_root+f[:path], f[:name], erb
      end

      #custome symbol funcitons
      csf = File.open(template_dir + "CustomSymbolFunctions").read
      write_file (game_root+ custom_symbol_functions[:dir]), custom_symbol_functions[:name], csf.gsub("SC", scatter)

      #gaffs
      gaff = File.open(template_dir + "Gaffs").read
      write_file (game_root+ gaffs[:dir]), gaffs[:name], gaff.gsub("SC", scatter)

      puts "Generate files into Dir #{game_root}"
    end

    def generate_config_scripts( scanner, params = {} )
      gid = params[:gid]
      bonus = true
      bonus_index = 1
      doubleup = true
      doubleup_index = 2
      rmlp = true
      rmlp_index = 3
      stage_count = 4
      template_dir = Pathname.new(File.dirname(__FILE__) + '/../lib/rg_gen/configurations/templates')
      paytable = File.basename(params[:paytable])
      paytable_config = File.basename(params[:paytable_config])
      themereg = "100L#{gid}.themereg"
      theme_config = themereg.gsub(/\.themereg/, '-000.config')
      binreg   = "G00#{gid}.binreg"
      registry = paytable.gsub 'paytable', 'registry'
      templates = {'themereg.template' => themereg, 'binreg.template' => binreg, 'registry.template' => registry}

      templates.each_pair do |k, v|
        tf = File.open(template_dir + "#{k}").read
        erb = ERB.new(tf).result(binding)
        puts erb.to_s
      end
    end

    private
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
  end

end
