Gem::Specification.new do |s|
  s.name          = 'bomp'
  s.version       = '1.0.5.1.2'
  s.summary       = 'A collision detection library for Ruby'
  s.description   = "Ruby collision-detection library for axis-aligned rectangles, inspired by 'bump.lua' but using native Ruby capabilities"
  s.authors       = 'SealtielFreak'
  s.email         = 'SealtielFreak@yandex.com'
  s.files         = Dir['**/**'].grep_v(/.gem$/)
  s.require_paths = %w[lib sample]
  s.homepage      = 'https://github.com/SealtielFreak/bomp.rb/blob/main/README.md'
  s.metadata      = { "source_code_uri" => "https://github.com/SealtielFreak/bomp.rb" }
  s.license       = 'MIT'
  s.required_ruby_version = '>= 2.5.0'
end
