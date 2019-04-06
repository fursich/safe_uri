
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "safe_uri/version"

Gem::Specification.new do |spec|
  spec.name          = "safe_uri"
  spec.version       = SafeURI::VERSION
  spec.authors       = ["Koji Onishi"]
  spec.email         = ["fursich0@gmail.com"]
  spec.required_ruby_version = '>= 2.3.0'

  spec.summary       = %q{a simple, safe alternative for URI.#open and Kernel.#open. With SafeURI.open you are not affected by pipe character injection that potentailly leads to various vulnerabilities.}
  spec.description   = %q{SafeURI is an alternative implementation that allows you to open an URI with safer approach - with SafeURI.#open, you can always force to use URI.parse(url).open, or File.open(filename) depending on the provided argument. The pipe character '|' is NOT accepted as it does not delegate to Kernel.#open (falls back to File.#open), unlike URI.#open that falls back to Kernel.#open when un-openable arguments are given.}
  spec.homepage      = 'https://github.com/fursich/safe_uri'
  spec.license       = "MIT"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "addressable"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
