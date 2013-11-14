# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ldap_mapper/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Rob Lyon"]
  gem.email         = ["nosignsoflifehere@gmail.com"]
  gem.description   = %q{LdapMapper maps LDAP record to Ruby objects.}
  gem.summary       = %q{A Ruby object mapper for LDAP}
  gem.homepage      = "https://github.com/rlyon/ldap_mapper"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ldap_mapper"
  gem.require_paths = ["lib"]
  gem.version       = LdapMapper::Version

    # specify any dependencies here; for example:
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec" 
  gem.add_development_dependency "mocha"
  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "ladle"
  gem.add_development_dependency "flog"
  gem.add_development_dependency "reek"

  gem.add_runtime_dependency "net-ldap"
  gem.add_dependency 'activemodel',   ">= 3.0.0"
  gem.add_dependency 'activesupport',   ">= 3.0"
end
