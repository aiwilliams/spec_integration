Dir[File.dirname(__FILE__) + '/dsl/extensions/*.rb'].each { |f| require f }
require File.dirname(__FILE__) + '/dsl/navigation'
require File.dirname(__FILE__) + '/dsl/form'
require File.dirname(__FILE__) + '/dsl/integration_example_group'

module Spec
  module Integration
    module DSL # :nodoc:
    end
  end
end