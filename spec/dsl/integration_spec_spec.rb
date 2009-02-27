require File.dirname(__FILE__) + '/../spec_helper'

describe "An integration spec", :type => :integration do
  it "should provide all the normal integration support" do
    with_routing do |set|
      set.draw do |map|
        map.root :controller => 'integration_dsl'
        get "/"
        response.should_not be_nil
        open_session.should_not == @integration_session
      end
    end
    
    with_routing do |set|
      set.draw do |map|
        map.special_named "/", :controller => "integration_dsl"
        reset!
        special_named_path
      end
    end
  end
  
  it "should have the form dsl" do
    lambda { submit_form }.should_not raise_error(NoMethodError, /submit_form/)
  end
  
  it "should have the navigation dsl" do
    lambda { navigate_to }.should_not raise_error(NoMethodError, /navigate_to/)
  end
  
  it "should have the showing matchers" do
    be_showing("/path").should be_kind_of(Spec::Integration::Matchers::Showing)
  end
  
  it "should have the navigation matchers" do
    have_navigated_successfully("/path").should be_kind_of(Spec::Integration::Matchers::NavigateSuccessfully)
  end
end