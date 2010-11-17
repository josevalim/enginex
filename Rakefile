# encoding: UTF-8
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require File.join(File.dirname(__FILE__), 'lib', 'enginex')

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/*_test.rb'
  t.verbose = true
end

Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Enginex'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "enginex"
    s.version = Enginex::VERSION.dup
    s.summary = "Creates a Rails 3 engine with Rakefile, Gemfile and running tests"
    s.email = "jose.valim@plataformatec.com.br"
    s.homepage = "http://github.com/josevalim/enginex"
    s.description = "Creates a Rails 3 engine with Rakefile, Gemfile and running tests"
    s.authors = ['José Valim']
    s.files =  FileList["[A-Z]*", "lib/**/*"]
    s.bindir = "bin"
    s.executables = %w(enginex)
    s.add_dependency("thor", "~> 0.14.0")
    s.add_dependency("rails", "~> 3.0")
    s.add_dependency("rake", "~> 0.8")
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: gem install jeweler"
end
