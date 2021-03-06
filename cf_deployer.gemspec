# -*- encoding: utf-8 -*-
require File.expand_path('../lib/cf_deployer/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jame Brechtel", "Peter Zhao", "Patrick McFadden", "Rob Sweet"]
  gem.email         = ["jbrechtel@gmail.com", "peter.qs.zhao@gmail.com", "pemcfadden@gmail.com", "rob@ldg.net"]
  gem.description   = %q{For automatic blue green deployment flow on CloudFormation.}
  gem.summary       = %q{Support multiple components deployment using CloudFormation templates with multiple blue green strategies.}
  gem.homepage      = "http://github.com/manheim/cf_deployer"
  gem.license = 'MIT'

  gem.add_runtime_dependency 'aws-sdk', '~> 1.5'
  gem.add_runtime_dependency 'log4r'
  gem.add_runtime_dependency 'thor'
  gem.add_runtime_dependency 'inifile'
  gem.add_runtime_dependency 'rainbow'
  gem.add_runtime_dependency 'diffy'
  gem.add_runtime_dependency 'json-minify'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'pry-debugger'
  # gem.add_runtime_dependency 'openstack'
  # gem.add_runtime_dependency 'openstack_heat'

  gem.files         = `git ls-files`.split($\).reject {|f| f =~ /^samples\// }
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "cf_deployer"
  gem.require_paths = ["lib", '../ruby-openstack/lib', '../ruby-openstack_heat/lib']
  gem.version       = CfDeployer::VERSION
end
