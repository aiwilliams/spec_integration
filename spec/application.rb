class ApplicationController < ActionController::Base
  session :session_key => '_spec_integration', :secret => '1ad3fa0f557c45019a3736577fa3fe5e'
end