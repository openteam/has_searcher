$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'has_searcher/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'has_searcher'
  s.version     = HasSearcher::VERSION
  s.authors     = ['Dmitry Lihachev']
  s.email       = ['lda@openteam.ru']
  s.homepage    = 'http://github.com/openteam/has_searcher'
  s.summary     = 'Adds ability to construct search objects for indexed models'
  s.description = %q{This gem adds ability to construct search objects for indexed models, build search forms and execute searches.
                     It works with sunspot, inherited_resources and simple_form/formtastic}

  s.files = Dir['{app,config,db,lib}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'README.rdoc']

  s.add_dependency 'rails', '~> 3.2.6'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'sunspot_matchers'
  s.add_development_dependency 'sunspot_rails', '>= 2.0.0.pre'
  s.add_development_dependency 'sunspot_solr', '>= 2.0.0.pre'
end
