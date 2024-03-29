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
  spec.description   = %q{BioRuby Shell is a command line interface on BioRuby open source bioinformatics library. It provides easy-to-use analysis environment for bioinformatics.}
  spec.homepage      = "https://github.com/bioruby/bioruby-shell"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "bio", ">= 2.0.0"

  spec.add_development_dependency "bundler", ">= 2.2.10"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rdoc", ">= 6.3.1"
  spec.add_development_dependency "test-unit", "~> 3"
end
