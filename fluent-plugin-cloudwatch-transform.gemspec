# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-cloudwatch-transform"
  gem.version       = "0.0.8"
  gem.date          = '2015-05-06'
  gem.authors       = ["Ling Zhang"]
  gem.email         = ["zhangling.ice@gmail.com"]
  gem.summary       = %q{Fluentd output plugin for transform cloudwatch alerts }
  gem.description   = %q{FLuentd plugin for transform cloudwatch alerts}
  gem.homepage      = 'https://github.com/lingzhang-lyon/fluent-plugin-cloudwatch-transform'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($\)
  # gem.files         = ["lib/fluent/plugin/out_cloudwatch_transform.rb"]
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'fluentd', '~> 0.10', '>= 0.10.9'
  gem.add_development_dependency 'bundler', '~> 1.3'
  gem.add_development_dependency 'rake', '~> 0.9', '>= 0.9.2'
  gem.add_development_dependency 'rspec', '~> 2.11', '>= 2.11.0'
  gem.add_runtime_dependency "highwatermark", '~> 0.1', '>= 0.1.2'
end
