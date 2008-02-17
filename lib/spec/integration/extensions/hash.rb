module Spec
  module Integration
    module Extensions

      module Hash
        # Extend Hash to give it the ability to be converted to Rails'esque
        # HTML form field names and values. This is used to verify forms. See
        # Spec::Integration::DSL::FormExampleMethods.
        
        # {:somekey => [{:somekey => 'value'}, {:somekey => 'value2'}, {:otherkey => 'value3'}]}
        def to_fields(fields = {}, namespace = nil)
          each do |key, value|
            key = namespace ? "#{namespace}[#{key}]" : key
            case value
            when ::Hash
              value.to_fields(fields, key)
            when ::Array
              value.each do |v|
                case v
                when ::Hash
                  v.each do |key2, value2|
                    rebuild = fields["#{key}[][#{key2}]"] ||= []
                    rebuild << value2
                  end
                else
                  rebuild = fields["#{key}[]"] ||= []
                  rebuild << v
                end
              end
            else
              fields[key.to_s] = value
            end
          end
          fields
        end
      end

    end
  end
end

Hash.module_eval do
  include Spec::Integration::Extensions::Hash
end