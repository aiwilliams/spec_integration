SPEC_ROOT = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH << SPEC_ROOT # for application.rb

require "#{SPEC_ROOT}/../plugit/descriptor"

RAILS_ROOT = "#{SPEC_ROOT}/.."
$LOAD_PATH << "#{RAILS_ROOT}/lib"

require 'spec/integration'
require 'integration_dsl_controller'