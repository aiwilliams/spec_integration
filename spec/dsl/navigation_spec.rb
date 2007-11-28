require File.dirname(__FILE__) + '/../spec_helper'
require 'integration_dsl_controller'

describe "find_anchor", :type => :controller do
  include Spec::Integration::DSL
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