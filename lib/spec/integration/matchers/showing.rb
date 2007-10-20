module Spec
  module Integration
    module Matchers
      class Showing
        def initialize(path)
          @expected = path
        end

        def matches?(response)
          @actual = response.request.request_uri
          @actual == @expected
        end

        def failure_message
          "expected to be showing #{@expected} but was #{@actual}"
        end

        def negative_failure_message
          "expected not to be showing #{@expected}"
        end
      end

      def be_showing(path)
        Showing.new(path)
      end
    end
  end
end