lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = "fluent-plugin-zookeeper"
  spec.version = "0.1.2"
  spec.authors = ["Anton Tikhomirov"]
  spec.email   = ["anton.tikhomirov@cdnetworks.com"]

  spec.summary       = %q{Fluentd plugin for Apache Zookeeper}
  spec.description   = %q{Fluentd plugin for Apache Zookeeper}
  spec.homepage      = "https://github.com/antonshi/fluent-plugin-zookeeper"
  spec.license       = "Apache-2.0"

  test_files, files  = `git ls-files -z`.split("\x0").partition do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.files         = files
  spec.executables   = files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = test_files
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "test-unit", "~> 3.0"
  spec.add_runtime_dependency "fluentd", [">= 0.14.10", "< 2"]
  spec.add_runtime_dependency "oj", "~> 3.0"
  spec.add_runtime_dependency "zookeeper", "~> 1.0"
end
