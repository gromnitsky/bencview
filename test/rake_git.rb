#!/usr/bin/env ruby
# -*-ruby-*-
# :erb:

# This is a helper for your Rakefile. Read the comments for each
# function.

require 'git'
require 'pp'

# Return a list of files in a git repository _repdir_.
#
# Add this to your gem spec:
#
# spec = Gem::Specification.new {|i|
#   i.files = git_ls('.')
# }
#
# What it does is just collecting the list of the files from the git
# repository. The idea is to use that list for the gem spec. No more
# missing or redundant files in gems!
def git_ls(repdir, ignore_some = true)
  ignore = ['/?\.gitignore$']

  r = []
  g = Git.open repdir
  g.ls_files.each {|i, v|
    next if ignore_some && ignore.index {|ign| i.match(/#{ign}/) }
    r << i
  }
  r
end

pp git_ls('.') if __FILE__ == $0

# Don't remove this: falsework/0.2.2/naive/2010-12-26T04:50:00+02:00
