require File.dirname(__FILE__) + '/../spec_helper'

describe "An integration spec", :type => :integration do
  it "should provide all the normal integration support" do
    get "/"
    response.should_not be_nil
    open_session.should_not == @integration_session
  end
  
  it "should have the form dsl" do
    should respond_to("submit_form")
  end
  
  it "should have the navigation dsl" do
    should respond_to("navigate_to")
  end
  
  it "should have the showing matchers" do
    be_showing("/path").should be_kind_of(Spec::Integration::Matchers::Showing)
  end
  
  it "should have the navigation matchers" do
    have_navigated_successfully("/path").should be_kind_of(Spec::Integration::Matchers::NavigateSuccessfully)
  end
end