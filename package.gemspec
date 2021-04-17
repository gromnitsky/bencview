Gem::Specification.new do |s|
  s.version = '1.0.2'

  s.name = 'bencview'
  s.summary = "View .torrent files; JSON export/import"
  s.author = 'Alexander Gromnitsky'
  s.email = 'alexander.gromnitsky@gmail.com'
  s.homepage = 'https://github.com/gromnitsky/bencview'
  s.license = 'MIT'
  s.files = [
    'bencview',
    'bencview.rb',
    'json2bencode',
    'package.gemspec',
    'README.md',
  ]

  s.require_paths = ['.']
  s.bindir = '.'
  s.executables = ['bencview', 'json2bencode']

  s.add_runtime_dependency 'bencode', '~> 0.8.2'

  s.required_ruby_version = '>= 2.3.0'

  s.post_install_message = <<~END
    *************************************************************************
    If you were using bencview-0.0.x, please read
    #{s.homepage},
    for it's a different program now, totally incompatible w/ 0.0.x releases.
    *************************************************************************
  END
end
