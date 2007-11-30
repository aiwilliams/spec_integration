Dir[File.dirname(__FILE__) + '/extensions/*'].each { |f| require f }

module Spec
  module Integration
    module Extensions # :nodoc:
    end
  end
end