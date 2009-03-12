require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'caches_action', :type => :integration do
  it 'should work' do
    time_one = Time.local(2009,1,1)
    time_two = Time.local(2009,1,2)
    
    Time.stub!(:now).and_return(time_two)
    get '/caching_action'
    response.body.should == time_two.to_s
    
    with_caching do
      # Let us ensure that it is not cached from outside this block
      Time.stub!(:now).and_return(time_one)
      get '/caching_action'
      response.body.should == time_one.to_s
      
      # And now it is cached here
      Time.stub!(:now).and_return(time_two)
      get '/caching_action'
      response.body.should == time_one.to_s
    end
    
    # And now we should get fresh content
    get '/caching_action'
    response.body.should == time_two.to_s
  end
end