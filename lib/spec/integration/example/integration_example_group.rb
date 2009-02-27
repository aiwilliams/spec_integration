module Spec
  module Integration
    mattr_accessor :executing_integration_example
    
    module Example
      
      class IntegrationExample < Spec::Rails::Example::RailsExampleGroup # :nodoc:
        include Spec::Integration::DSL
        include Spec::Integration::Matchers
        include ActionController::RecordIdentifier
        include ActionController::Integration::Runner
        
        before :all do
          Spec::Integration.executing_integration_example = true
        end
        
        after :all do
          Spec::Integration.executing_integration_example = false
        end
        
        # Override ActionController::Integration::Runner method_missing to keep
        # RSpec be_ and have_ matchers working.
        #
        def method_missing(sym, *args, &block) # :nodoc:
          return Spec::Matchers::Be.new(sym, *args) if sym.starts_with?("be_")
          return has(sym, *args) if sym.starts_with?("have_")
          super
        end
        
        Spec::Example::ExampleGroupFactory.register(:integration, self)
      end
      
    end
  end
end