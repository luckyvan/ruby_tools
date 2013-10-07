#!/usr/bin/env ruby
# coding: UTF-8

require File.expand_path('../../test_helper',__FILE__)
require 'igt_env'


class TestIgtEnv < Test::Unit::TestCase
  must "has valid root dir like '/mnt/development'" do\
    if Dir.exist?('/cygdrive') then
      assert_equal IGTEnv.root, '/cygdrive/d/Development'
    else
      assert_equal IGTEnv.root, '/mnt/Development'
    end
  end
end
