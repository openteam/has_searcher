# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "has_searcher/version"

Gem::Specification.new do |s|
  s.name        = "has_searcher"
  s.version     = HasSearcher::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Dmitry Lihachev"]
  s.email       = ["lda@openteam.ru"]
  s.homepage    = "http://github.com/openteam/has_searcher"
  s.summary     = %q{Adds ability to construct search objects for indexed models}
  s.description = %q{This gem adds ability to construct search objects for indexed models.
                     It works with sunspot, inherited_resources and formtastic}

  s.add_dependency "rails", ["> 3.0.0", "< 3.2.0"]
  s.rubyforge_project = "has_searcher"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
