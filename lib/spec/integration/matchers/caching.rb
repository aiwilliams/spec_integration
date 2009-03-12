module Spec
  module Integration
    module Matchers
      
      class CacheAction < Struct.new(:name, :store_options, :controller_context) #:nodoc:
        def matches?(block)
          ActionController::Base.cache_store.reset
          block.call
          @key = name.is_a?(String) ? name : controller_context.controller.fragment_cache_key(name)
          @cached = ActionController::Base.cache_store.cached?(@key)
          @options_match = ActionController::Base.cache_store.writes(@key) == store_options
          @cached && @options_match
        end
        
        def failure_message
          reason = if @cached && !@options_match
            "the store options expected:\n  #{store_options.inspect}\n" +
            "do not match received:\n  #{ActionController::Base.cache_store.writes(@key).inspect}"
          elsif !@cached
            if ActionController::Base.cache_store.cache.any?
              "the cache only has #{ActionController::Base.cache_store.cache.to_yaml}."
            else
              "the cache is empty."
            end
          end
          "Expected block to cache action #{name.inspect} (#{@key}), but #{reason}"
        end
        
        def negative_failure_message
          "Expected block not to cache action #{name.inspect} (#{@key})"
        end
      end
      
      # See if an action gets cached
      #
      # Usage:
      #
      #   lambda { get :index }.should cache_action(:index)
      # 
      # You can pass in the name of an action which will then get
      # interpreted in the context of the current controller. Alternatively,
      # you can pass in a whole +Hash+ for +url_for+ defining all your
      # paramaters.
      def cache_action(action, store_options = {})
        Spec::Integration.ensure_caching_enabled
        action = { :action => action } unless action.is_a?(Hash)
        CacheAction.new(action, store_options, self)
      end
      
      # See if a fragment gets cached.
      #
      # The name you pass in can be any name you have given your fragment.
      # This would typically be a +String+.
      #
      # Usage:
      #
      #   lambda { get :index }.should cache('my_caching')
      # 
      def cache(name)
        CacheAction.new(name, self)
      end
      alias_method :cache_fragment, :cache
      
      class ExpireAction #:nodoc:
        def initialize(name, controller_context)
          @name = name
          @controller_context = controller_context
        end
        
        # Call the block of code passed to this matcher and see if
        # our action has been removed from the cache.
        #
        # We determine the +fragment_cache_key+ here, taking the effort to
        # pass in the controller to this class, because this method only
        # works in the context of a request. Calling the block gives us that
        # request.
        def matches?(block)
          ActionController::Base.cache_store.reset
          block.call
          @key = @name.is_a?(String) ? @name : @controller_context.controller.fragment_cache_key(@name)
          return ActionController::Base.cache_store.expired?(@key)
        end
        
        def failure_message
          reason = if ActionController::Base.cache_store.expired.any?
            "the cache has only expired #{ActionController::Base.cache_store.expired.to_yaml}."
          else
            "nothing was expired."
          end
          "Expected block to expire action #{@name.inspect} (#{@key}), but #{reason}"
        end
        
        def negative_failure_message
          "Expected block not to expire #{@name.inspect} (#{@key})"
        end
      end
      
      # See if an action is expired
      #
      # Usage:
      # 
      #   lambda { get :index }.should expire_action(:index)
      # 
      # You can pass in the name of an action which will then get
      # interpreted in the context of the current controller. Alternatively,
      # you can pass in a whole +Hash+ for +url_for+ defining all your
      # paramaters.
      #
      # This is a shortcut method to +expire+.
      def expire_action(action)
        action = { :action => action } unless action.is_a?(Hash)
        expire(action)
      end
      
      # See if a fragment is expired
      #
      # The name you pass in can be any name you have given your fragment.
      # This would typically be a +String+.
      #
      # Usage:
      # 
      #   lambda { get :index }.should expire('my_cached_something')
      # 
      def expire(name)
        ExpireAction.new(name, self)
      end
      alias_method :expire_fragment, :expire
      
    end
  end
end