module Spec
  module Integration
    module DSL

      module FormExampleMethods
        # Makes assertions about the existance and validity of a form.
        # The _selector_ argument may be
        # <tt>a Symbol or String that is the form id</tt>
        # <tt>a String that is a valid CSS selector</tt>
        #
        def sees_form(selector, values, options = {})
          options = {
            :verify_field_enablment => false,
            :verify_field_values => true
          }.merge(options)
          
          selector = selector.to_s
          forms, tried_selector = nil, false
          forms = css_select "form##{selector}" if selector =~ /^[a-zA-Z_\-0-9]+$/
          if forms.blank?
            tried_selector = true
            forms = css_select selector
          end

          violated "Found no form having id or matching selector '#{selector}'" if forms.blank?
          if forms.size > 1
            violated "Found more than one form having id ##{selector}" if !tried_selector
            violated "Found more than one form matching selector '#{selector}'"
          end

          form = forms[0]
          values.to_fields.each do |name, value|
            form_fields = css_select form, "input, select, textarea"
            matching_field = form_fields.detect {|field| field["name"] == name || field["name"] == "#{name}[]"}
            violated "Could not find a form field having the name '#{name}'" unless matching_field
            if options[:verify_field_values]
              matching_field["value"].should == value
            end
            if options[:verify_field_enablment] && matching_field["disabled"]
              violated "Form '#{selector}' has a field named '#{name}', but it is disabled. You may not submit values to it."
            end
            if matching_field["type"] == "file" && form["enctype"] != "multipart/form-data"
              violated "Form '#{selector}' has a file field named '#{name}', but the enctype is not multipart/form-data"
            end
            if matching_field.name == "select"
              should have_tag(matching_field, "option[value=#{value}]")
            end
          end
          form
        end

        # Submit a form to the application after verifying it exists in the
        # current response body. Hidden fields are extracted from the rendered
        # form and submitted as well.
        #
        # If you are looking to use an alternate HTTP method, realize that the
        # intention is that you would generate your form appropriately to
        # include the hidden _method field.
        #
        # This method supports a couple of argument sequences:
        #
        #   submit_form(selector = 'form', values = {}, options = {})
        #   submit_form(values = {}, options = {})
        #
        # The former allows you to specify which form to submit when there are
        # multiple forms on a page. _selector_ may be the id of the form or
        # a valid CSS selector.
        #
        # The latter allows you to assume that there is only one form on the page.
        # It essentially defaults selector to the CSS selector 'form'.
        #
        # You CAN use ActionController::TestUploadFile's as parameters, thanks to
        # some work done by RubyRedRick!
        #
        # Supported options are:
        #
        # * <tt>:verify_field_enablment</tt> - will fail submission if a field is
        #   disabled. Default is true.
        # * <tt>:verify_field_values</tt> - will fail submission if a field does
        #   not have the provided value already. This is really mostly useful
        #   when calling _sees_form_ directly. Default is false.
        #
        def submit_form(*args)
          selector = 'form'
          values   = {}
          options = {
            :verify_field_enablment => true,
            :verify_field_values    => false,
            :load_hiddens           => true
          }
          
          case args.size
          when 1
            if args.first.is_a?(Hash)
              values = args.first
            else
              selector = args.first
            end
          when 2
            if args.first.is_a?(Hash)
              values = args.first
              options.update(args.last)
            else
              selector, values = *args
            end
          when 3
            selector, values, = *args
            options.update(args.last)
          end
          
          form = sees_form(selector, values, options)
          submit_to form["action"], load_hidden_fields(values, form), form["method"]
        end
        
        private
          def load_hidden_fields(values, form)
            hiddens = css_select(form, "input[type=hidden]")
            return values if hiddens.blank?
            
            given_values = values.to_fields
            hidden_values = hiddens.inject({}) do |memo,h|
              field_name, field_value = h['name'], h['value']
              if field_name =~ /\[\]/
                (memo[field_name] ||= []) << field_value
              else
                memo[field_name] = field_value
              end
              memo
            end
            given_values.update hidden_values.reject {|k,v| given_values.keys.include?(k.to_s) }
            ActionController::UrlEncodedPairParser.new(given_values).result
          end
      end
      
    end
  end
end