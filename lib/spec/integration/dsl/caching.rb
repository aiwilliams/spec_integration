module Spec
  module Integration
    module DSL
      
      # Provides a context within which view caching is enabled across
      # requests made within the block.
      #
      def with_caching
        prior_perform_caching = ActionController::Base.perform_caching
        ActionController::Base.perform_caching = true
        ActionController::Base.cache_store.reset
        ActionController::Base.cache_store.perform_caching = true
        yield
      ensure
        ActionController::Base.cache_store.perform_caching = false
        ActionController::Base.perform_caching = prior_perform_caching
      end
      
    end
  end
end