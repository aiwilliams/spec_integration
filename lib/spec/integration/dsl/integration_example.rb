module Spec
  module Integration
    module DSL
      
      class IntegrationExample < ActionController::IntegrationTest
        remove_method :default_test if respond_to?(:default_test)
        cattr_accessor :fixture_path, :use_transactional_fixtures, :use_instantiated_fixtures, :global_fixtures
        
        class << self
          def configure
            self.fixture_table_names = []
            self.fixture_class_names = {}
          end

          def before_eval #:nodoc:
            super
            prepend_before {setup}
            append_after {teardown}
            configure
          end
        end
        
 #       include Spec::DSL::ExampleModule
        include Spec::Rails::Matchers
        include Spec::Integration::Matchers
        include Spec::Integration::DSL::NavigationExampleMethods
        include Spec::Integration::DSL::FormExampleMethods

        include ActionController::RecordIdentifier
        
        def initialize(example) #:nodoc:
          @_result = ::Test::Unit::TestResult.new
          super
        end
        
        Spec::DSL::BehaviourFactory.add_example_class(:integration, self)
      end
      
    end
  end
end
