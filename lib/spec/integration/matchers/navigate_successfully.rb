module Spec
  module Integration
    module Matchers
      
      class NavigateSuccessfully #:nodoc:
        def initialize(example, where)
          @example, @where = example, where
        end
        
        def matches?(response)
          if response.error? || response.body =~ /Exception caught/
            @failure_message = extract_exception(@example)
          elsif response.missing?
            @failure_message = "Missing document #{@example.request.method}'ing #{@where}"
          end
          @failure_message.nil?
        end
        
        def failure_message
          @failure_message
        end
        
        def negative_failure_message
          "expected failure navigating #{@where}"
        end
        
        private
          def extract_exception(example)
            exception_in_controller_action = example.controller.rescued_exception
            message = "Unexpected #{example.response.response_code} error #{example.request.method}'ing #{@where}"
            if exception_in_controller_action
              message << "\n#{exception_in_controller_action.message}"
              if exception_in_controller_action.respond_to? :line_number
                message << "\nOccurred on line #{exception_in_controller_action.line_number} in #{exception_in_controller_action.file_name}"
              else
                backtrace = Spec::Runner::QuietBacktraceTweaker.new.tweak_backtrace(exception_in_controller_action)
                message << "\n#{backtrace * "\n"}"
              end
            else
              if example.response.body =~ %r{<h1>(.*?)</h1>\s*?<pre>(.*?)</pre>}mi
                first, second = $1, $2
                message << "\n\n#{first.gsub(/\s+/m, ' ').strip}\n\n#{second}"
              end
              message << "\n\n#{$1}" if example.response.body =~ %r{<div id="Full-Trace".*?>\s*?<pre><code>(.*?)</code></pre>\s*</div>}mi
            end
            message
          end
      end
      
      # Specify that a response should be a good one: successful, not missing,
      # no server errors, etc.
      #
      def have_navigated_successfully(where = request.request_uri)
        NavigateSuccessfully.new(self, where)
      end
      
    end
  end
end