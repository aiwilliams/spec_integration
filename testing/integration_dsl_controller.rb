class IntegrationDslController < ApplicationController
  def exploding
    raise "This will blow up!"
  end
end