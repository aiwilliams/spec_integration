module Spec
  module Integration
    module Matchers
      class DisplayObject # :nodoc:
        include ActionController::RecordIdentifier
        
        def initialize(objects, example)
          @objects = objects
          @example = example
        end
        
        def matches?(response)
          @currently_matching = nil
          @objects.each do |e|
            @currently_matching = e
            response.should @example.have_tag("##{dom_id(@currently_matching)}", :count => 1)
          end
          true
        rescue
          false
        end
        
        def failure_message
          "expected to find element having id #{dom_id(@currently_matching)} but none was found"
        end
        
        def negative_failure_message
          "expected not to find elements having ids #{@objects.collect {|e| dom_id(e)}.inspect}"
        end
      end
      
      # Specify that a response should be displaying an object according to
      # the pattern of using _dom_id_.
      #
      def display_object(*objects)
        DisplayObject.new(objects.flatten, self)
      end
      alias_method :display_objects, :display_object
    end
  end
end