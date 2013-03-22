# -*-ruby-*-

require 'rake/clean'
require 'rake/testtask'
gem 'rdoc'
require 'rdoc/task'
require 'rubygems/package_task'

require_relative 'lib/bencview/meta'
include Bencview

require_relative 'test/rake_git'

spec = Gem::Specification.new {|i|
  i.name = Meta::NAME
  i.version = `bin/#{i.name} -V`
  i.summary = 'Torrent file viewer & metadata cleaner'
  i.description = i.summary + '.' # eat this, freaking rubygems
  i.author = Meta::AUTHOR
  i.email = Meta::EMAIL
  i.homepage = Meta::HOMEPAGE

  i.platform = Gem::Platform::RUBY
  i.required_ruby_version = '>= 1.9.2'
  i.files = git_ls('.')

  i.executables = FileList['bin/*'].gsub(/^bin\//, '')

  i.test_files = FileList['test/test_*.rb']

  i.rdoc_options << '-m' << 'doc/README.rdoc'
  i.extra_rdoc_files = FileList['doc/*']

  i.add_dependency('open4', '~> 1.3.0')
  i.add_dependency('bencode', '~> 0.8.0')

  i.add_development_dependency "git", "~> 1.2.5"
}

Gem::PackageTask.new(spec).define

task default: [:repackage]

RDoc::Task.new('html') {|i|
  i.main = 'doc/README.rdoc'
  i.rdoc_files = FileList['doc/*', 'lib/**/*.rb']
#  i.rdoc_files.exclude("lib/**/some-nasty-staff")
}

Rake::TestTask.new {|i|
  i.test_files = FileList['test/test_*.rb']
}
