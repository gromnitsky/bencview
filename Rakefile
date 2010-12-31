# -*-ruby-*-

require 'rake'
require 'rake/gempackagetask'
require 'rake/clean'
require 'rake/rdoctask'
require 'rake/testtask'

require_relative 'test/rake_git'

spec = Gem::Specification.new {|i|
  i.name = 'bencview'
  i.version = `bin/#{i.name} -V`
  i.summary = 'Torrent file viewer & metadata cleaner'
  i.author = 'Alexander Gromnitsky'
  i.email = 'alexander.gromnitsky@gmail.com'
  i.homepage = "http://github.com/gromnitsky/#{i.name}"
  i.platform = Gem::Platform::RUBY
  i.required_ruby_version = '>= 1.9.2'
  i.files = git_ls('.')

  i.executables = FileList['bin/*'].gsub(/^bin\//, '')
  i.default_executable = i.name
  
  i.test_files = FileList['test/test_*.rb']
  
  i.rdoc_options << '-m' << 'doc/README.rdoc'
  i.extra_rdoc_files = FileList['doc/*']

  i.add_dependency('open4', '>= 1.0.1')
  i.add_dependency('bencode', '>= 0.6.0')
}

Rake::GemPackageTask.new(spec).define

task default: [:repackage]

Rake::RDocTask.new('doc') {|i|
  i.main = 'doc/README.rdoc'
  i.rdoc_files = FileList['doc/*', 'lib/**/*.rb']
#  i.rdoc_files.exclude("lib/**/some-nasty-staff")
}

Rake::TestTask.new {|i|
  i.test_files = FileList['test/test_*.rb']
}
