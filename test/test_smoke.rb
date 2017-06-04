#!/usr/bin/env ruby

require_relative '../bencview'

require 'fileutils'
require "test/unit"

class HashWalk < Test::Unit::TestCase
  def test_simple
    r = Bencview.hash_walk({q: {w: "hello", e: [1,2]}}) {|str| str.upcase}
    assert_equal({q: {w: "HELLO", e: [1,2]}}, r)
  end
end

class Smoke < Test::Unit::TestCase
  def setup
    @tojson = "#{__dir__}/../bencview"
    @fromjson = "#{__dir__}/../json2bencode"
    @torrent = "#{__dir__}/data/landau.torrent"
    @tmp = "#{__dir__}/tmp.landau.torrent"
  end

  def test_json
    system("#{@tojson} -j < #{@torrent} | #{@fromjson} > #{@tmp}")
    assert_equal(0, $?)
    system("cmp #{@torrent} #{@tmp}")
    assert_equal(0, $?)
  end

  def teardown
    FileUtils.rm @tmp, force: 1
  end
end
