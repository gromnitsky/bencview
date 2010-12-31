require_relative 'helper'

class TestBencview_1272419217 < MiniTest::Unit::TestCase
  CMD = cmd('bencview') # get path to the exe & cd to tests directory
  
  def setup
    # this runs every time before test_*
  end

  def test_foobar
    fail "\u0430\u0439\u043D\u044D\u043D\u044D".encode(Encoding.default_external, 'UTF-8')
  end
end
