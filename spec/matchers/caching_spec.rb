require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class CachingController < ActionController::Base
  caches_action :cache_store_params, :expires_in => 15.minutes
  def cache_store_params
    render :text => Time.now.to_s
  end
end

describe 'cache_action', :type => :integration do
  it 'should match when the action is cached' do
    lambda do
      get '/caching_action'
    end.should cache_action(:caching_action)
  end
  
  it 'should not match when the action is not cached' do
    lambda do
      get '/'
    end.should_not cache_action(:index)
  end
  
  it 'should work with url_for hash' do
    lambda do
      get '/'
    end.should_not cache_action(:action => :index)
  end
  
  it 'should allow specifying the expected cache store params' do
    lambda do
      get '/caching/cache_store_params'
    end.should cache_action({
        :controller => 'caching',
        :action => :cache_store_params
      }, :expires_in => 15.minutes)
  end
end
