$:.push File.expand_path("../lib", __FILE__)

require "cubic/version"

Gem::Specification.new do |s|
  s.name        = "cubic"
  s.version     = Cubic::VERSION
  s.authors     = ["Roomorama Developers"]
  s.email       = ["developers@roomorama.com"]
  s.homepage    = "https://github.com/roomorama/cubic"
  s.summary     = "Cubic measures"
  s.description = "Cubic provides a unified interface for metric systems"

  s.files = Dir["lib/**/*", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "librato-metrics", "~> 1.6.0"
end
