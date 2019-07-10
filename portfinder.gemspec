# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "portfinder/version"

Gem::Specification.new do |s|
  s.name	= "portfinder"
  s.version	= Portfinder::VERSION
  s.authors	= ["Tahmid Shakil"]
  s.email	= ["at.shakil.92@gmail.com"]

  s.summary	= "A port scanner implementation in pure ruby"
  s.description = "Portfinder is a ruby based port scanner with features like \
network/CIDR scanning, port randomization, hostname discovery and banner \
grabbing."
  s.homepage = "https://github.com/atshakil/portfinder"
  s.license = "MIT"

  s.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  s.require_paths = ["lib"]

  s.bindir = "bin"
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }

  s.required_ruby_version = [">= 2.2.0"]

  s.extra_rdoc_files = ["README.md"]
  s.rdoc_options =
    %w[-t Portfinder -m README.md -N --markup markdown]

  s.add_dependency "slop", "~> 4.4"

  s.add_development_dependency "appraisal", "~> 2.2"
  s.add_development_dependency "bundler", "~> 1.15"
  s.add_development_dependency "minitest", "~> 5.0"
  s.add_development_dependency "rake", "~> 12.0"
  s.add_development_dependency "simplecov", "~> 0.13"

  if ENV["TRAVIS"]
    s.add_development_dependency "codeclimate-test-reporter", "~> 1.0.8"
  end
end
