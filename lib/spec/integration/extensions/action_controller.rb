module Spec
  module Integration
    module Extensions
      
      # The point of all this is to simply capture the exceptions of an action
      # during an integration testing request (get, post, put, etc). This
      # exception is later used in the navigation matcher to show the failure
      # if navigation did not succeed due to an exception.
      #
      module ActionController
        def self.included(base)
          base.extend(ClassMethods)
          base.metaclass.module_eval do
            alias_method_chain :new, :integration_extensions
          end
        end
        
        module ClassMethods #:nodoc:
          def new_with_integration_extensions(*args)
            controller = new_without_integration_extensions(*args)
            if Spec::Integration.executing_integration_example
              controller.use_rails_error_handling!
              controller.metaclass.module_eval do
                attr_reader :rescued_exception
                def rescue_action(e)
                  @rescued_exception = e
                  super
                end
              end
            end
            controller
          end
        end
      end
      
    end
  end
end

ActionController::Base.module_eval do
  include Spec::Integration::Extensions::ActionController
end