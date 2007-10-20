ActionController::Base.class_eval do
  alias_method :rescue_action, :rescue_action_without_fast_errors

  attr_reader :rescued_exception
  def rescue_action_with_integration_support(e)
    @rescued_exception = e
    rescue_action_without_integration_support e
  end
  alias_method_chain :rescue_action, :integration_support
end