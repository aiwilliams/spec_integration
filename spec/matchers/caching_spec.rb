require File.dirname(__FILE__) + '/../spec_helper'

describe 'cache_action', :type => :integration do
  it 'should match the action is cached' do
    lambda do
      get '/caching_action'
    end.should cache_action(:caching_action)
  end
  
  it 'should not match when the action is not cached' do
    lambda do
      get '/'
    end.should_not cache_action(:index)
  end
end
