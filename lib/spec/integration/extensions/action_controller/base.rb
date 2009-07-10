module Spec
  module Integration
    module Extensions
      
      # The point of all this is to simply capture the exceptions of an action
      # during an integration testing request (get, post, put, etc). This
      # exception is later used in the navigation matcher to show the failure
      # if navigation did not succeed due to an exception.
      #
      module ActionController
        
        module InstanceMethods #:nodoc:
          attr_reader :rescued_exception
          def rescue_action_locally(exception)
            @rescued_exception = exception
            super
          end
        end
        
      end
    end
  end
end

ActionController::Base.module_eval do
  include Spec::Integration::Extensions::ActionController::InstanceMethods
end