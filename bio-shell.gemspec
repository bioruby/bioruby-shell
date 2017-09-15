# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "bio/shell/version"

Gem::Specification.new do |spec|
  spec.name          = "bio-shell"
  spec.version       = Bio::Shell::VERSION
  spec.authors       = ["BioRuby project"]
  spec.email         = ["staff@bioruby.org"]

  spec.summary       = %q{BioRuby Shell: interactive analysis environment for BioRuby}
  spec.description   = %q{BioRuby Shell is a command-line based interacitve analysis enviroment for BioRuby open source bioinformatics library.}
  spec.homepage      = "https://github.com/bioruby/bioruby-shell"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "bio", ">= 1.5.1"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rdoc", "~> 5"
  spec.add_development_dependency "test-unit", "~> 3"
end
