# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "paybox/version"

Gem::Specification.new do |s|
  s.name        = "paybox"
  s.version     = Paybox::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Franck Verrot","Guillaume Barillot"]
  s.email       = ["franck@verrot.fr"]
  s.homepage    = "http://www.verrot.fr"
  s.summary     = %q{Payment Gateway to Paybox's services}
  s.description = %q{Payment Gateway to Paybox's services}

  s.rubyforge_project = "paybox"

  s.add_dependency 'activesupport'
  s.add_dependency 'i18n'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-core'
  s.add_development_dependency 'rspec-expectations'
  s.add_development_dependency 'fakeweb'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
