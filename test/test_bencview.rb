require_relative 'helper'
require 'bencode'
require 'digest/md5'

class TestBencview_1272419217 < MiniTest::Unit::TestCase
  CMD = cmd('bencview') # get path to the exe & cd to tests directory
  
  def setup
    # this runs every time before test_*
  end

  def test_cleaner
    c = cmd('bencview_clean')
    r = Trestle.cmd_run "#{c} qwerty asdfgh"
    assert_equal(2, r[0])
    assert_match(/No such file or directory/, r[1])

    r = Trestle.cmd_run "#{c} -v torrent/[rutracker.org]2642547.torrent"
    assert_equal(0, r[0])

    t = BEncode.load_file r[2].strip
    assert_equal('Leech without any rating!', t['comment'])
    assert_equal([], t['announce-list'])
    assert_equal('http://tracker.openbittorrent.com/announce', t['announce'])
  end

  def test_viewer
    r = Trestle.cmd_run "#{CMD} qwerty asdfgh"
    assert_equal(2, r[0])
    assert_match(/No such file or directory/, r[1])

    r = Trestle.cmd_run "#{CMD} torrent/*.torrent"
    assert_equal(0, r[0])
    refute_equal(0, r[2].size)

    r = Trestle.cmd_run "#{CMD} torrent/[rutracker.org]314407.torrent torrent/[rutracker.org].t3128973.torrent"
    assert_equal(0, r[0])
    achieved = Digest::MD5.hexdigest(r[2].encode('UTF-8', Encoding.default_external))
    expected = Digest::MD5.hexdigest(File.read('viewer_output_01.txt').encode('UTF-8', 'KOI8-U'))
    assert_equal(expected, achieved)
  end
  
end
