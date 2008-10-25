module Spec
  module Integration
    module Matchers
      class HaveLinkTo # :nodoc:
        include ActionController::RecordIdentifier
        
        def initialize(href, example)
          @href = href
          @example = example
        end
        
        def matches?(response)
          response.should @example.have_tag('a[href=?]', @href)
          true
        rescue
          false
        end
        
        def failure_message
          "expected to find a link to #{@href} but none was found"
        end
        
        def negative_failure_message
          "expected not to find a link to #{@href}"
        end
      end
      
      # Specify that a response should have a link with the specified href value.
      #
      def have_link_to(href)
        HaveLinkTo.new(href, self)
      end
    end
  end
end