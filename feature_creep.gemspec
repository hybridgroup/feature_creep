# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "feature_creep/version"

Gem::Specification.new do |s|
  s.name = "feature_creep"
  s.version = FeatureCreep::VERSION
  s.authors = ["Christian Trosclair"]
  s.email       = ["xn@gotham.us"]
  s.description = "Feature Flag implementation"
  s.summary = "Extensible Feature Flags"
  s.homepage = "https://github.com/xn/feature_creep"

  s.require_paths = ["lib"]

  s.rubyforge_project = "feature_creep"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec", "~> 2.10.0"
  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "jeweler", "~> 1.6.4"
  s.add_development_dependency "bourne", "1.0"
  s.add_development_dependency "mocha", "0.9.8"
  s.add_development_dependency "pry", "0.9.10"
  s.add_development_dependency "feature_creep-redis"
  s.add_development_dependency "feature_creep-simple_strategy", "0.0.2"

end
