require File.dirname(__FILE__) + "/../spec/environment"

unless defined? DATABASE_ADAPTER
  $: << "#{SPEC_ROOT}"
  $: << "#{PLUGIN_ROOT}/lib"
  $: << "#{RSPEC_ROOT}/lib"
  $: << "#{ACTIONPACK_ROOT}/lib"
  $: << "#{ACTIVERECORD_ROOT}/lib"
  $: << "#{ACTIVESUPPORT_ROOT}/lib"
  $: << "#{RSPEC_ON_RAILS_ROOT}/lib"

  require 'active_support'
  require 'active_record'
  require 'action_controller'
  require 'action_view'
  
  require 'spec'
  require 'spec/rails'
  require 'spec/integration'

  require 'logger'
  RAILS_DEFAULT_LOGGER = Logger.new("#{SUPPORT_TEMP}/test.log")
  RAILS_DEFAULT_LOGGER.level = Logger::DEBUG
  ActiveRecord::Base.logger = RAILS_DEFAULT_LOGGER
end