require 'rubygems'
gem 'rake'
require 'rake'
require 'rake/rdoctask'

require "#{File.dirname(__FILE__)}/spec/environment"

desc "Run all specs"
task :spec => ["spec:libs:checkout"] do
  require "#{RSPEC_ROOT}/lib/spec/rake/spectask"
  Spec::Rake::SpecTask.new :spec do |t|
    t.spec_opts = ['--options', "\"#{SPEC_ROOT}/spec.opts\""]
    t.spec_files = FileList["#{SPEC_ROOT}/**/*_spec.rb"]
  end
end

namespace :spec do
  namespace :libs do
    desc "Prepare workspace for running our specs"
    task :checkout do
      mkdir_p SUPPORT_LIB
      libs = {
        RSPEC_ROOT          => "http://rspec.rubyforge.org/svn/trunk/rspec",
        RSPEC_ON_RAILS_ROOT => "http://rspec.rubyforge.org/svn/trunk/rspec_on_rails",
        ACTIONPACK_ROOT     => "http://svn.rubyonrails.org/rails/trunk/actionpack/",
        ACTIVESUPPORT_ROOT  => "http://svn.rubyonrails.org/rails/trunk/activesupport/"
      }
      needed = libs.keys.select { |dir| not File.directory?(dir) }
      if needed.empty?
        puts "Support libraries are in place. Skipping checkout."
      else
        needed.each { |root| system "svn export #{libs[root]} #{root}" }
      end
    end
    
    desc "Remove libs from tmp directory"
    task :clean do
      rm_rf SUPPORT_LIB
      puts "cleaned #{SUPPORT_LIB}"
    end
  end
end

Rake::RDocTask.new(:doc) do |r|
  r.title = "Rails Scenarios Plugin"
  r.main = "README"
  r.options << "--line-numbers"
  r.rdoc_files.include("README", "LICENSE", "lib/**/*.rb")
  r.rdoc_dir = "doc"
end
  
task :default => :spec