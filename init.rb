if config.environment == "test"
  require 'spec/rails'
  require 'spec/integration/extensions'
  require 'spec/integration/matchers'
  require 'spec/integration/dsl'
end