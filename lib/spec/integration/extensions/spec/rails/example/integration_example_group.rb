Spec::Rails::Example::IntegrationExampleGroup.module_eval do
  include Spec::Integration::DSL
  include Spec::Integration::Matchers
  include ActionController::RecordIdentifier
  
  # Override ActionController::Integration::Runner method_missing to keep
  # RSpec be_ and have_ matchers working.
  #
  def method_missing(sym, *args, &block) # :nodoc:
    return Spec::Matchers::Be.new(sym, *args) if sym.to_s.starts_with?("be_")
    return has(sym, *args) if sym.to_s.starts_with?("have_")
    super
  end
end
