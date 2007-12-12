class IntegrationDslController < ActionController::Base
  def exploding
    raise "This will blow up!"
  end
end