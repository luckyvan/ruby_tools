#!/usr/bin/env ruby
# coding: UTF-8

require File.expand_path('../../test_helper',__FILE__)
require 'paytable_scanner'
require 'paytable_tokenizer'


class TestPaytableScanner < Test::Unit::TestCase
  def setup
    @tokenizer = PaytableTokenizer.new()
    @tokenizer.parse(File.open("test/unit/paytable/AVV040998.paytable").read)
    @scanner = PaytableScanner.new()
    @scanner.parse(@tokenizer.tokens)

    @tokenizer1 = PaytableTokenizer.new()
    @tokenizer1.parse(File.open("test/unit/paytable/AVV040999.paytable").read)
    @scanner1 = PaytableScanner.new()
    @scanner1.parse(@tokenizer1.tokens)
  end

  must "top level elements" do
    assert_equal 5, @scanner.elements.length
  end

  must "has 2-4 stages" do
    assert_equal 2, @scanner.stages.length
    assert_equal 4, @scanner1.stages.length
  end

  must "include RMLP" do
    assert_nil @scanner.rmlp
    assert_not_nil @scanner1.rmlp
  end

  must "include doubleup based on paytable" do
    assert_not_nil @scanner1.doubleup
    assert_nil @scanner.doubleup
  end

  must "include bonus based on paytable" do
    assert_not_nil @scanner1.bonus
    assert_not_nil @scanner.bonus
  end

  must "has correct symbol sets" do
    assert_equal ["TT", "DD", "7A", "7B", "7C",
                  "7D", "7E", "F1", "F2", "F3", "F4", "BN"], @scanner.base.symbols
    assert_equal ["WW", "M1", "M2", "M3", "M4",
                  "F5", "F6", "F7", "F8", "D1","B1"], @scanner1.base.symbols
  end

  must "has a win category which can lead to Stage1" do
    assert_equal 150, @scanner.base.trigger_index
    assert_equal 80, @scanner1.base.trigger_index
  end

  must "have valid bonus symbol" do
    assert_equal "BN", @scanner.base.bonus_symbol
    assert_equal "B1", @scanner1.base.bonus_symbol
  end
end
