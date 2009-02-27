ActionController::Base.session = {
  :key => '_spec_integration_session',
  :secret => '1ad3fa0f557c45019a3736577fa3fe5e'
}

class ApplicationController < ActionController::Base
end