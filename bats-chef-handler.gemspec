# -*- encoding: utf-8 -*-

$:.push File.expand_path('../lib/chef/handler', __FILE__)

require 'bats_handler_version'

Gem::Specification.new do |s|
  s.name = 'bats-chef-handler'
  s.version = Chef::Handler::BatsHandler::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Joe Miller']
  s.email = ['joeym@joeym.net']
  s.homepage = 'https://github.com/joemiller/bats-chef-handler'
  s.summary = 'BATS tests handler'
  s.description = 'Run BATS tests at the end of a chef run, similar to minitest-chef-handler'
  s.files = %w(LICENSE README.md) + Dir.glob('lib/**/*')
  s.require_paths = ['lib']
  s.add_development_dependency "chef", "> 10.14"
  s.license = 'MIT'
end
