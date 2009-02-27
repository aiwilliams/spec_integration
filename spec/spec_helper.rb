SPEC_ROOT = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(SPEC_ROOT) # for application_controller.rb
 
RAILS_ROOT = File.expand_path("#{SPEC_ROOT}/..")
$LOAD_PATH.unshift("#{RAILS_ROOT}/lib")

require 'rubygems'
require 'active_support'
require 'active_record'
require 'action_pack'
require 'action_controller'
require 'action_mailer'

require 'rails/version'

require 'spec/integration'
require 'integration_dsl_controller'