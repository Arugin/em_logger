# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'em_logger/version'

Gem::Specification.new do |gem|
  gem.name        = 'em_logger'
  gem.version     = EventMachine::Logger::VERSION
  gem.homepage    = 'https://github.com/Arugin/em_logger'

  gem.author      = 'Valery Mayatsky'
  gem.email       = 'valerymayatsky@gmail.com'
  gem.description = 'An async wrapper for ruby logger for EventMachine applications.'
  gem.summary     = 'An async wrapper for ruby logger for EventMachine applications.'

  gem.add_dependency 'eventmachine', '>= 0.12.10'
  gem.add_development_dependency 'bundler', '~> 1.0'

  gem.executables = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  gem.files       = `git ls-files`.split("\n")
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")

  gem.require_paths = ['lib']
end
