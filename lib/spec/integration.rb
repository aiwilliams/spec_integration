require 'spec/rails'
require 'spec/integration/extensions/hash'
require 'spec/integration/matchers'
require 'spec/integration/dsl'
require 'spec/integration/extensions/action_controller/base'
require 'spec/integration/extensions/action_controller/caching'
require 'spec/integration/extensions/spec/rails/example/integration_example_group'

module Spec # :nodoc:
  module Integration # :nodoc:
    
    def ensure_caching_enabled
      unless ActionController::Base.perform_caching
        raise "ActiveRecord::Base.caches_action is not registering a caching filter when classes are loaded. Please modify your test environment file to have 'config.action_controller.perform_caching = true'."
      end
    end
    module_function :ensure_caching_enabled
    
  end
end

ActionController::Base.cache_store = Spec::Integration::Extensions::ActionController::Caching::TestStore.new