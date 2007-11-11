module Spec
  module Integration
    module DSL

      module FormExampleMethods
        # Makes assertions about the existance and validity of a form.
        # The _selector_ argument may be
        #   <tt>a Symbol or String that is the form id</tt>
        #   <tt>a String that is a valid CSS selector</tt>
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

        # Submits the form where _selector_ is the id of the form, a valid CSS
        # selector, or a Hash with a single key that is the id of the form or
        # a valid CSS selector.
        #
        # Values are verified to have fields rendered for them in the current
        # response body. Hidden fields are extracted from the rendered form
        # and submitted as well.
        #
        # If you are looking to use an alternate HTTP method, realize that the
        # intention is that you would generate your form appropriately to
        # include the hidden _method field.
        #
        # Options:
        #   <tt>:verify_field_enablment</tt>  - will fail submission if a field is
        #       disabled. Default is true.
        #   <tt>:verify_field_values</tt>     - will fail submission if a field does
        #       not have the provided value already. This is really mostly useful
        #       when calling _sees_form_ directly. Default is false.
        #
        # NOTE: action_controller/integration.rb does not allow for posting
        # ActionController::TestUploadedFile. I'd love to see someone make
        # that work.
        def submits_form(selector, values = {}, options = {})
          options = {
            :verify_field_enablment => true,
            :verify_field_values    => false
          }.merge(options)
          
          if selector.is_a?(Hash) && values.blank?
            raise ArgumentError, "requires (id, values), (css_selector, values), or ({:id_of_form => {}})" if selector.size != 1
            selector, values = selector.keys.first, selector
          end

          form = sees_form(selector, values, options)
          values.update hidden_values(form)
          submit_to form["action"], values, form["method"]
        end

        def hidden_values(form)
          hiddens = css_select(form, "input[type=hidden]")
          pairs = hiddens.inject({}) {|p,h| p[h["name"]] = h["value"]; p}
          ActionController::UrlEncodedPairParser.new(pairs).result
        end
      end

    end
  end
end