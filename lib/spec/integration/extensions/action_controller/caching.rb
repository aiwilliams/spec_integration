module Spec
  module Integration
    module Extensions
      module ActionController
        module Caching
          
          module ClassMethods #:nodoc:
            def cache_page(content, path)
              test_page_cached << path
            end
            
            def expire_page(path)
              test_page_expired << path
            end
            
            def cached?(path)
              test_page_cached.include?(path)
            end
            
            def expired?(path)
              test_page_expired.include?(path)
            end
            
            def reset_page_cache!
              test_page_cached.clear
              test_page_expired.clear
            end
          end
          
          module InstanceMethods
            # See if the page caching mechanism has cached a given url. This takes
            # the same options as +url_for+.
            def cached?(options = {})
              self.class.cached?(test_cache_url(options))
            end
            
            # See if the page caching mechanism has expired a given url. This 
            # takes the same options as +url_for+.
            def expired?(options = {})
              self.class.expired?(test_cache_url(options))
            end
            
            private
              def test_cache_url(options) #:nodoc:
                url_for(options.merge({ :only_path => true, :skip_relative_url_root => true }))
              end
          end
          
          class TestStore < ActiveSupport::Cache::Store
            attr_accessor :perform_caching
            attr_reader :expired, :expiration_patterns, :cache
            
            def initialize(perform_caching = false) #:nodoc:
              @perform_caching = perform_caching
              @cache, @writes = {}, {}
              @expired, @expiration_patterns = [], []
            end
            
            def reset
              [@cache, @writes, @expired, @expiration_patterns].each(&:clear)
            end
            
            def read(name, options = nil) #:nodoc:
              super
              @cache[name] if perform_caching
            end
            
            def write(name, value, options = nil) #:nodoc:
              super
              @cache[name] = value if perform_caching
              @writes[name] = options || {}
            end
            
            def delete(name, options = nil) #:nodoc:
              super
              @expired << name
            end
            
            def delete_matched(matcher, options = nil) #:nodoc:
              super
              @expiration_patterns << matcher
            end
            
            def cached?(name)
              @writes.has_key?(name)
            end
            
            def expired?(name_or_matcher)
              @expired.include?(name_or_matcher) || @expiration_patterns.detect { |matcher| name_or_matcher =~ matcher }
            end
            
            def writes(name)
              @writes[name]
            end
          end
          
        end
      end
    end
  end
end

ActionController::Base.module_eval do
  include Spec::Integration::Extensions::ActionController::Caching::InstanceMethods
  extend  Spec::Integration::Extensions::ActionController::Caching::ClassMethods
  
  @@test_page_cached  = [] # keep track of what gets cached
  @@test_page_expired = [] # keeg track of what gets expired
  cattr_accessor :test_page_cached
  cattr_accessor :test_page_expired
end