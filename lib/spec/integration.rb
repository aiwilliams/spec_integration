require 'spec'
require 'spec/rails'
require 'spec/integration/extensions/action_controller/base'
require 'spec/integration/extensions/action_controller/caching'
require 'spec/integration/extensions/hash'
require 'spec/integration/matchers'
require 'spec/integration/dsl'
require 'spec/integration/example/integration_example_group'

module Spec # :nodoc:
  module Integration # :nodoc:
  end
end

ActionController::Base.cache_store = Spec::Integration::Extensions::ActionController::Caching::TestStore.new