module Spec
  module Integration
    module Matchers
      class Showing # :nodoc:
        def initialize(path)
          @expected = path
        end
        
        def matches?(response)
          @actual = response.request.request_uri
          actual_path, query_params_in_actual = @actual.split('?')
          expected_path, query_params_in_expected = @expected.split('?')
          if !query_params_in_expected
            @actual = actual_path
            @expected = expected_path
          end
          @actual == @expected
        end
        
        def failure_message
          "expected to be showing #{@expected} but was #{@actual}"
        end
        
        def negative_failure_message
          "expected not to be showing #{@expected}"
        end
      end
      
      # Specify that a response should be showing _path_.
      #
      # When writing integration tests, whether a ton of redirects happen or
      # not isn't important. You want to be sure that a particular path is
      # being shown.
      #
      # This will not attempt to match query parameters unless you provide
      # them in your path ('my/path?a=b'). Why? Because sometimes you don't
      # care what the query parameters are!
      #
      def be_showing(path)
        Showing.new(path)
      end
    end
  end
end