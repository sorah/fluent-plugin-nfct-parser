
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "fluent-plugin-nfct-parser/version"

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-nfct-parser"
  spec.version       = FluentPluginNfctParser::VERSION
  spec.authors       = ["Sorah Fukumori"]
  spec.email         = ["sorah@cookpad.com"]

  spec.summary       = %q{Fluentd parser plugin for libnetfilter_conntrack snprintf format}
  spec.homepage      = "https://github.com/sorah/fluent-plugin-nfct-parser"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "fluentd"
  spec.add_dependency "strptime"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "test-unit"
end
