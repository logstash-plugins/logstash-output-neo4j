ROOT = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.join(ROOT, 'lib')
Dir.glob('lib/**').each{ |d| $LOAD_PATH.unshift(File.join(ROOT, d)) }

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rspec'
require 'rspec/core/rake_task'

desc "Specs all at ones."
RSpec::Core::RakeTask.new(:spec) do |t|
  t.fail_on_error = true
  t.verbose = false
end
