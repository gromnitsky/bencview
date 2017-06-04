Gem::Specification.new do |s|
  s.version = '1.0.0'

  s.name = 'bencview'
  s.summary = "View .torrent files; JSON export/import"
  s.author = 'Alexander Gromnitsky'
  s.email = 'alexander.gromnitsky@gmail.com'
  s.homepage = 'https://github.com/gromnitsky/bencview'
  s.license = 'MIT'
  s.files = `git ls-files`.split

  s.bindir = '.'
  s.executables = ['bencview.rb', 'json2bencode']

  s.add_runtime_dependency 'bencode', '~> 0.8.2'

  s.required_ruby_version = '>= 2.3.0'
end
