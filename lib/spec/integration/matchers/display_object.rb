module Spec
  module Integration
    module Matchers
      class DisplayObject # :nodoc:
        include ActionController::RecordIdentifier
        
        def initialize(object, example)
          @object = object
          @example = example
        end
        
        def matches?(response)
          response.should @example.have_tag("##{dom_id(@object)}")
          true
        rescue
          false
        end
        
        def failure_message
          "expected to find element having id #{dom_id(@object)} but none was found"
        end
        
        def negative_failure_message
          "expected not to find element having id #{dom_id(@object)}"
        end
      end
      
      # Specify that a response should be displaying an object according to
      # the pattern of using _dom_id_.
      #
      def display_object(object)
        DisplayObject.new(object, self)
      end
    end
  end
end