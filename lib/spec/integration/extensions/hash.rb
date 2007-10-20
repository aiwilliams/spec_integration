module Spec
  module Integration
    module Extensions

      module Hash
        def to_fields(fields = {}, namespace = nil)
          each do |key, value|
            key = namespace ? "#{namespace}[#{key}]" : key
            case value
            when ::Hash
              value.to_fields(fields, key)
            when ::Array
              fields["#{key}[]"] = value
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

Hash.send :include, Spec::Integration::Extensions::Hash