# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'solid_use_case/version'

Gem::Specification.new do |spec|
  spec.name          = "solid_use_case"
  spec.version       = SolidUseCase::VERSION
  spec.authors       = ["Gilbert"]
  spec.email         = ["gilbertbgarza@gmail.com"]
  spec.description   = %q{Create use cases the way they were meant to be. Easily verify inputs at each step and seamlessly fail with custom error data and convenient pattern matching.}
  spec.summary       = %q{A flexible UseCase pattern that works *with* your workflow, not against it.}
  spec.homepage      = "https://github.com/mindeavor/solid_use_case"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '~> 2.0'

  spec.add_dependency "deterministic", '~> 0.6.0'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14.1"
end
