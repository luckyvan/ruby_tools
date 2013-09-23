#!/usr/bin/env ruby
# coding: UTF-8
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'


class PaytableAnalyzer
  @delims = ['[', ']', '{', '}', '=']

  def analyze input
    tokens = tokenize( input )
    result = []

    while (!tokens.empty?()) do
      node, tokens = get_node(tokens)
      result << node
    end
    result
  end

  def tokenize( input )
    tokens = []
    input.each_line do |line|
      #erase comment and spaces both front and back ends.
      line = line.gsub(/\/\/.*/, '').gsub(/^\s*/,'').gsub(/\s*$/,'')

      if('[' == line[0]) then
        raise "line #{line} does not end with ']' when begins with '['" unless line[-1] == ']'
        tokens << '[' << line[1..-2] << ']'
      elsif('{' == line[0] or '}' == line[0]) then
        tokens << line[0]
      elsif(line =~ /\s*=\s*/)
        tokens << '='
        tokens << line.gsub(/\s*=.*/, '')
        tokens << line.gsub(/.*=\s*/, '')
      end
    end

    tokens
  end

  def get_node( tokens )
    tokens =  match('[', tokens)
    node = {
      :type => :element,
      :name => tokens[0],
      :content => [],
    };
    tokens =  match(tokens[0], tokens)
    tokens =  match(']', tokens)
    tokens =  match('{', tokens)
    while('}' != tokens[0]) do
      if('[' == tokens[0]) then
        sub_node, tokens = get_node( tokens )
        node[:content] << sub_node
      elsif ('=' == tokens[0])
        equation, tokens = get_equation(tokens)
        node[:content] << equation
      elsif ('{' == tokens[0] )
        win, tokens = get_win_category( tokens )
        node[:content] << win
      end
    end
    tokens = match('}', tokens)
    return node, tokens
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

paytable = File.open("AVV040998.paytable").read

pa = PaytableAnalyzer.new

top_level_nodes = pa.analyze(paytable)

base_game = pa.find_by_name("base game", top_level_nodes)
base_game_wins = pa.find_by_name("win evaluation", base_game[:content])
symbols_by_equations = pa.find_by_name("symbol defines", base_game[:content])
symbols = symbols_by_equations[:content].map{|e| e[:right_op]}
puts "game stage number: #{top_level_nodes.length - 2}"
puts "symbols: #{symbols}"

bonus_win_category = base_game_wins[:content].index do |category|
  raise "not category: #{category}" unless category[:type] == :category
  found = false
  category[:equations].each do |equation|
    found = true if equation[:right_op] =~ /trigger/
  end
  found
end

puts "base win category: #{bonus_win_category}"

bonus_symbol = 'haha'
base_game_wins[:content][bonus_win_category][:equations].each do |eq|
  bonus_symbol = eq[:right_op].split( /,\s*/ )[-1] if eq[:left_op] =~ /scatter/
end
puts "bonus symbol: #{bonus_symbol}"




