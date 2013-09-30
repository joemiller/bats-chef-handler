$:.push File.expand_path('../lib/chef/handler', __FILE__)

require 'bats_handler_version'
require 'bundler/gem_tasks'


desc "push .gem to rubygems.org"
task :release do
  system "gem push bats-chef-handler-#{Chef::Handler::BatsHandler::VERSION}.gem"
end

task :default => :build
