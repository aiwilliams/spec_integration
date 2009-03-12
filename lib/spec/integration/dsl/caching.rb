module Spec
  module Integration
    module DSL
      
      # Provides a context within which view caching is enabled across
      # requests made within the block.
      #
      def with_caching
        Spec::Integration.ensure_caching_enabled
        ActionController::Base.cache_store.reset
        ActionController::Base.cache_store.perform_caching = true
        yield
      ensure
        ActionController::Base.cache_store.perform_caching = false
      end
      
    end
  end
end