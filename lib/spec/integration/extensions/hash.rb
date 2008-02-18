module Spec
  module Integration
    module Extensions

      module Hash # :nodoc:
        def name_with_prefix(prefix, name)
          prefix ? "#{prefix}[#{name}]" : name.to_s
        end

        def requestify(parameters, collector = [], prefix=nil)
          if Hash === parameters
            return collector if parameters.empty?
            parameters.each { |k,v| requestify(v, collector, name_with_prefix(prefix, k)) }
          elsif Array === parameters
            parameters.each { |v| requestify(v, collector, name_with_prefix(prefix, "")) }
          elsif prefix.nil?
            collector
          else
            collector << [prefix, parameters]
          end
          collector
        end
        
        # Extend Hash to give it the ability to be converted to Rails'esque
        # HTML form field names and values. This is used to verify forms.
        #
        # The return value is an Array of key value pairs. This is to maintain
        # the behaviour that a browser will submit enabled fields in the order
        # they are found in the document. Rails leverages that behaviour to
        # construct data structures from the request parameters. Specifically,
        # when you have an Array of Hashes, the Hash a parameter appears in
        # depends on something like this:
        #
        #   one[][one]=1&one[][two]=2&one[][three]=3one[][one]=4&one[][five]=5
        #   => [{'one' => 1, 'two' => 2, 'three' => 3}{'one' => 4, 'five' => 5}]
        #
        def to_fields
          requestify(self)
        end
      end

    end
  end
end

Hash.module_eval do
  include Spec::Integration::Extensions::Hash
end