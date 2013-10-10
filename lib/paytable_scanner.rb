#!/usr/bin/env ruby
# coding: UTF-8
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'pathname'

class PaytableScanner
  attr_accessor :elements, :stages
  attr_accessor :rmlp, :base, :doubleup, :bonus

  def initialize
    @elements = []
    @stages   = []
    @rmlp = nil
    @base = nil
  end

  def parse(tokens)
    while (!tokens.empty?) do
      elem, tokens = get_element( tokens )
      @elements << elem
    end
  end

private
  def get_element( tokens )
    tokens =  match('[', tokens)
    elem = Element.new(tokens[0])

    tokens =  match(tokens[0], tokens)
    tokens =  match(']', tokens)
    tokens =  match('{', tokens)

    while('}' != tokens[0]) do
      if('[' == tokens[0]) then
        sub_elem, tokens = get_element( tokens )
        elem.content << sub_elem
      elsif ('=' == tokens[0])
        equation, tokens = get_equation(tokens)
        elem.content << equation
      elsif ('{' == tokens[0] )
        win, tokens = get_win_category( tokens )
        elem.content << win
      end
    end

    tokens = match('}', tokens)

    case elem.name
    when /base game/ then @base = BaseGame.new(elem.name, elem.content); stages << @base
    when /Stage(\d)/ then
      index = $1
      game = nil
      if (elem.content[0].name =~ /slot/) then
        game = BonusGame.new(elem.name, elem.content)
        @bonus = game
      else
        game = DoubleUp.new(elem.name, elem.content)
        @doubleup = game
      end
      game.index = index
      @stages << game
    when /RMLPFlash/ then
      @rmlp = Rmlp.new(elem.name, elem.content); stages << @rmlp
      @rmlp.index = stages.length - 1
    end

    return elem, tokens
  end

  def get_equation( tokens )
    equation = {
      :type => :equation,
      :left_op => tokens[1],
      :right_op => tokens[2],
    };
    tokens =  match('=', tokens)
    tokens =  match(tokens[0], tokens)
    tokens =  match(tokens[0], tokens)
    return equation, tokens
  end

  def get_win_category( tokens )
    category = {
      :type => :category,
      :equations => []
    };

    tokens =  match('{', tokens)
    while('=' == tokens[0]) do
      equation, tokens = get_equation( tokens )
      category[:equations] << equation
    end
    tokens =  match('}', tokens)
    return category, tokens
  end

  def match( token, tokens )
    raise "\'#{tokens[0]}\' does not match \'#{token}\'" unless (token == tokens[0])

    return tokens[1..-1]
  end

  def find_by_name( name, nodes )
    nodes.each do |n|
      return n if name == n[:name]
    end
  end
end

class Element
  attr_accessor :name, :content
  include Enumerable

  def initialize(name, content = [])
    @name = name
    @content = content
  end

  def each
    content.each { |e| yield(e) }
  end
end

class Stage < Element
end

class SlotGame < Stage
  def wins
    content.select{|c| c.name == "win evaluation" }[0].content
  end

  def trigger_index
    wins.index do |w|
      w[:equations][0][:right_op].include?("trigger")
    end
  end
end

class BaseGame < SlotGame
  def symbols
    symbol_defines = content.select {|elem| elem.name =~ /symbol defines/}
    symbol_defines[0].collect {|eqa| eqa[:right_op]}
  end

  def symbol_substitutions
    content.find {|elem| elem.name =~ /symbol substitutions/}.content.inject({})do |h,s|
      h[ s[:left_op] ] = s[:right_op]
      h
    end
  end

  def bonus_symbol
    wins = wins()
    index = trigger_index()
    scatters = wins[trigger_index][:equations][1][:right_op].split(/\s*,\s*/)
    symbols = symbols()
    substitutions = symbol_substitutions

    sym = nil
    scatters.each do |s|
      if ((s != "XX") and (substitutions.keys.include?(s))) then
        sym = substitutions[s].split(/\s*,\s*/)[0]
      else
        sym = s if symbols.include? s
      end
    end
    sym
  end
end

class BonusGame < SlotGame
  attr_accessor :index
end

class DoubleUp< Stage
  attr_accessor :index
end

class Rmlp < Stage
  attr_accessor :index
end

