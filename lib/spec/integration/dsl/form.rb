module Spec
  module Integration
    module DSL

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
        form_fields = css_select form, "input, select, textarea"
        values.to_fields.each do |name, value|
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
            response.should have_tag(matching_field, "option[value=#{value}]")
          end
        end
        [form, form_fields]
      end

      # Submit a form to the application after verifying it exists in the
      # current response body.
      #
      # If you are looking to use an alternate HTTP method, realize that the
      # intention is that you would generate your form appropriately to
      # include the hidden _method field. This will be handled by adding
      # that value to your form fields.
      #
      # Other hidden fields will also be added
      # unless you pass the option <tt>:include_hidden</tt> with the value
      # false. You may find this necessary when you have Arrays of Hashes -
      # they are sufficiently too complex to handle correctly in the
      # conversion to request parameters, merged with hiddens, and converted
      # back to the expected data structure.
      #
      # This method supports a couple of argument sequences:
      #
      #   submit_form(selector = 'form', values = {}, options = {})
      #   submit_form(values = {}, options = {})
      #
      # The former allows you to specify which form to submit when there are
      # multiple forms on a page. _selector_ may be the id of the form or a
      # valid CSS selector.
      #
      # The latter allows you to assume that there is only one form on the
      # page. It essentially defaults selector to the CSS selector 'form'.
      # Note that to pass options, you will need to use parens, as in:
      #
      #   submit_form({}, :include_hidden => false)
      #
      # You CAN use ActionController::TestUploadFile's as parameters, thanks
      # to some work done by RubyRedRick!
      #
      # Supported options are:
      #
      # * <tt>:include_hidden</tt> - defaults to true. Hidden fields will be
      #   included into your supplied params.
      # * <tt>:verify_field_enablment</tt> - will fail submission if a field
      #   is disabled. Default is true.
      # * <tt>:verify_field_values</tt> - will fail submission if a field
      #   does not have the provided value already. This is really mostly
      #   useful when calling _sees_form_ directly. Default is false.
      #
      def submit_form(*args)
        selector = 'form'
        values   = {}
        options = {
          :verify_field_enablment => true,
          :verify_field_values    => false,
          :include_hidden         => true
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
        
        form, fields = sees_form(selector, values, options)
        violated "Form '#{selector}' is missing an 'action' attribute" if form["action"].blank?
        submit_to form["action"], collect_form_params(values, form, fields, options[:include_hidden]), form["method"], options
      end
      
      private
        def collect_form_params(values, form, fields, include_hidden = true)
          given_values = values.to_fields
          overridden_array_field_names, string_form_params, file_form_params = [], [], []
          fields.each do |field|
            field_name = field['name']
            next if overridden_array_field_names.include?(field_name)
            submit = given_values.select {|k,v| k == field_name}
            if submit.blank?
              if (field['type'] == 'hidden' && include_hidden) || field_name == '_method'
                submit = [field['name'], field['value']]
                string_form_params << submit
              end
            else
              if submit.size == 1 && ActionController::TestUploadedFile === submit.first.last
                file_form_params.concat(submit)
              else
                overridden_array_field_names << field_name if field_name =~ /\[\]/
                string_form_params.concat(submit)
              end
            end
          end
          form_params = Rack::Utils.parse_nested_query(string_form_params.collect {|k,v| "#{k}=#{CGI.escape(v)}"}.join('&'))
          file_form_params.each do |k,v|
            Rack::Utils.normalize_params(form_params, k, v)
          end
          form_params
        end
      
    end
  end
end