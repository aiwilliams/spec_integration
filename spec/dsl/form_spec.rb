require File.dirname(__FILE__) + '/../spec_helper'
require 'integration_dsl_controller'

describe "submit_form", :type => :controller do
  include Spec::Integration::DSL
  controller_name :integration_dsl
  
  before do
    response.stub!(:body).and_return %{
      <form action="/order" id="order_form" method="get"></form>
      <form action="/cancel" id="cancel_form" method="post"></form>
    }
  end
  
  it "should find the form having the given id" do
    should_receive(:post).with("/cancel", {})
    submit_form "cancel_form"
  end
  
  it "should use method of the rendered form" do
    should_receive(:get).with("/order", {})
    submit_form "order_form"
  end
end