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
    def new_game( params = {} )
      gid = params[:gid]
      rgid = params[:rgid]
      root = params[:root]
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
      params = params.merge(default)
      from = params[:resources]
      to = params[:game_output]
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

        resource_files.each do |path|
          if (not exclusion.include?(path.basename.to_s)) then
            new_dir = path.dirname.sub(f.to_s, to.to_s)
            new_path = path.to_s.sub(f.to_s, to.to_s)
            if not new_dir.exist? then
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
      output = Pathname.new(params[:game_output])
      game_id = params[:gid]
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
      bonus_symbol = scanner.base.bonus_symbol
      gaffs   = {
        :name => "Game-00#{game_id}.Show.script",
        :dir  => Pathname.new("System.Show/Scripts"),
      }
      template_dir = Pathname.new(File.dirname(__FILE__) + '/../lib/rg_gen/symbols/templates')
      gaff_template_dir = Pathname.new(File.dirname(__FILE__) + '/../lib/rg_gen/gaff/templates')

      #check paths
      Checker.check_dir(root)
      Checker.check_dir(game_root)
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
      gaff_template = File.open(gaff_template_dir + "gaff.template.script").read
      gaff_erb = ERB.new(gaff_template).result(binding)
      FileUtils.rm_r(game_root+gaffs[:dir])
      write_file (game_root+ gaffs[:dir]), gaffs[:name], gaff_erb

      puts "Generate files into Dir #{game_root}"
    end

    def generate_config_scripts( scanner, params = {} )
      gid = params[:gid]
      bonus = (scanner.bonus != nil)
      bonus_index = scanner.bonus.index if bonus
      doubleup = (scanner.doubleup != nil)
      doubleup_index = scanner.doubleup.index if doubleup
      rmlp = (scanner.rmlp != nil)
      rmlp_index = scanner.rmlp.index if rmlp
      stage_count = scanner.stages.length
      template_dir = Pathname.new(File.dirname(__FILE__) + '/../lib/rg_gen/configurations/templates')
      paytable = File.basename(params[:paytable])
      paytable_config = File.basename(params[:paytable_config])
      themereg = "100L#{gid}.themereg"
      theme_config = themereg.gsub(/\.themereg/, '-000.config')
      binreg   = "G00#{gid}.binreg"
      registry = paytable.gsub 'paytable', 'registry'
      themebase = params[:game_base] + 'Configuration/Themes'
      binbase = params[:game_base] + 'Configuration/Bins'
      registrybase = params[:game_base] + 'Configuration/Registries'
      paytablebase = params[:game_base] + 'Configuration/Paytables'
      game_variables_base = params[:game_base] + 'Configuration/Game.Main/Scripts/Presentation'
      game_varaiables = "GameVariables.lua"
      templates = {'themereg.template' => themebase+themereg, 'binreg.template' => binbase+binreg, 'registry.template' => registrybase+registry, 'GameVariables.template.lua' => game_variables_base + game_varaiables}
      bonus_trigger = (bonus) ? scanner.base.trigger_index : 0
      proj_output = params[:proj_output]
      libshare = Pathname.new(File.dirname(__FILE__) + '/../lib/rg_gen/rmlp/project/LibShared')

      FileUtils.cp_r libshare, proj_output

      FileUtils.rm_rf registrybase

      templates.each_pair do |k, v|
        tf = File.open(template_dir + "#{k}").read
        erb = ERB.new(tf).result(binding)
        write_file v.dirname, v.basename, erb
      end
      FileUtils.cp params[:paytable], paytablebase
      FileUtils.cp params[:paytable_config], paytablebase
    end

    def generate_rmlp(params)
      game_base = params[:game_base]
      gid = params[:gid]
      binbase = game_base + 'Configuration/Bins'
      themebase = params[:game_base] + 'Configuration/Themes'
      proj_output = params[:proj_output]
      ebgreg = Pathname.new(File.dirname(__FILE__) + '/../lib/rg_gen/configurations/EBG.ebgreg')
      rmlp_config_src = Pathname.new(File.dirname(__FILE__) + '/../lib/rg_gen/configurations/rmlp.config')
      rmlp_config_dst = themebase + "100L#{gid}-03-000.config"
      rmlp_resource = Pathname.new(File.dirname(__FILE__) + '/../lib/rg_gen/rmlp/Resources')
      rmlp_proj = Pathname.new(File.dirname(__FILE__) + '/../lib/rg_gen/rmlp/project')

      Dir.glob("#{rmlp_resource}/*").each {|src| FileUtils.cp_r src, game_base }
      Dir.glob("#{rmlp_proj}/*").each {|src| FileUtils.cp_r src, proj_output }

      FileUtils.cp ebgreg, binbase
      FileUtils.cp rmlp_config_src, rmlp_config_dst
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
      File.open(file_path + file_name, "w").write(contents)
    end

    private :collect_movies, :write_file
  end
end
