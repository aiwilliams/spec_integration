require File.dirname(__FILE__) + '/../spec_helper'

describe "find_anchors", :type => :controller do
  include Spec::Integration::DSL
  include Spec::Integration::Matchers
  controller_name :integration_dsl
  
  before do
    response.stub!(:body).and_return %{<a href="/lala"></a>}
  end
  
  it "should find the anchor having the given href" do
    find_anchors('/lala').should_not be_nil
  end
  
  it "should violate when count is not as expected" do
    lambda do
      find_anchors('/lala', :count => 0)
    end.should raise_error(Spec::Expectations::ExpectationNotMetError)
  end
end

describe "have_navigated_successfully", :type => :integration do
  it "should report the exception in the failure message" do
    with_routing do |set|; set.draw do |map|
      map.connect '/exploding', :controller => 'integration_dsl', :action => 'exploding'
      get '/exploding'
      lambda do
        response.should have_navigated_successfully
      end.should raise_error(Spec::Expectations::ExpectationNotMetError, /This will blow up!/)
    end; end
  end
end