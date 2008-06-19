require File.expand_path(File.dirname(__FILE__) + "/../testing/plugit_descriptor")

def fail_with(message)
  raise_error(Spec::Expectations::ExpectationNotMetError, message)
end

require 'spec/integration'
require 'integration_dsl_controller'