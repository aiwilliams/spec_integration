require File.dirname(__FILE__) + '/../spec_helper'
require 'integration_dsl_controller'

describe Spec::Integration::DSL, "find_anchor", :type => :controller do
  controller_name :integration_dsl
  
  before do
    response.stub!(:body).and_return %{<a href="/lala"></a>}
  end
  
  it "should find the anchor having the given href" do
    find_anchor('/lala').should_not be_nil
  end
  
  it "should violate when count is not as expected" do
    lambda do
      find_anchor('/lala', :count => 0)
    end.should raise_error(Spec::Expectations::ExpectationNotMetError)
  end
end

describe Spec::Integration::DSL, "have_navigated_successfully", :type => :controller do
  controller_name :integration_dsl
  
  it "should report the exception in the failure message" do
    with_routing do |set|; set.draw do |map|
      map.connect ':controller/:action/:id'
      get :exploding
      lambda do
        should have_navigated_successfully
      end.should fail_with(/This will blow up!/)
    end; end
  end
end