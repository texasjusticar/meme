# -*- encoding: utf-8 -*-
require File.expand_path('../lib/meme/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Eric Hodel", "Ethan Burrow"]
  gem.email         = [""]
  gem.description   = %q{}
  gem.summary       = %q{}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = ["meme"]
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "meme"
  gem.require_paths = ["lib"]
  gem.version       = Meme::VERSION
end
