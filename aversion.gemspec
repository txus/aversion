# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aversion/version'

Gem::Specification.new do |gem|
  gem.name          = "txus-aversion"
  gem.version       = Aversion::VERSION
  gem.authors       = ["Josep M. Bach"]
  gem.email         = ["josep.m.bach@gmail.com"]
  gem.description   = %q{Make your Ruby objects versionable}
  gem.summary       = %q{Make your Ruby objects versionable}
  gem.homepage      = "https://github.com/txus/aversion"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
