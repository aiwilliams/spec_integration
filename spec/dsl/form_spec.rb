require File.dirname(__FILE__) + '/../spec_helper'
require 'integration_dsl_controller'

describe "submit_form", :type => :controller do
  include Spec::Integration::DSL
  controller_name :integration_dsl
  
  before do
    response.stub!(:body).and_return %{
      <form action="/order" id="order_form" method="get"></form>
      <form action="/cancel" id="cancel_form" method="post"></form>
      <form action="/repeat" class="special" method="post"></form>
    }
  end
  
  it "should find the form having the given id" do
    should_receive(:post).with("/cancel", {})
    submit_form "cancel_form"
  end
  
  it 'should find the form matching the given css selector' do
    should_receive(:post).with("/repeat", {})
    submit_form '.special'
  end
  
  it 'should use single form without having to specify' do
    response.stub!(:body).and_return %{
      <form action="/single" method="get"></form>
    }
    should_receive(:get).with('/single', {})
    submit_form
  end
  
  it "should use method of the rendered form" do
    should_receive(:get).with("/order", {})
    submit_form "order_form"
  end
  
  it 'should extract hidden fields from form, except for which values are supplied' do
    response.stub!(:body).and_return %{
      <form action="/hiddens" method="get">
        <input type="hidden" name="not_overridden" value="from_form" />
        <input type="hidden" name="overridden" value="from_form" />
        <input type="hidden" name="deeply[overridden]" value="from_form" />
        <input type="hidden" name="deeply[not_overridden]" value="from_form" />
      </form>
    }
    should_receive(:get).with("/hiddens", {
      'not_overridden' => ['from_form'],
      'overridden' => ['not_from_form'],
      'deeply' => {
        'not_overridden' => ['from_form'],
        'overridden' => ['not_from_form']
      }
    })
    submit_form :overridden => 'not_from_form', :deeply => {:overridden => 'not_from_form'}
  end
end

describe 'Expectations parsing query parameters: ' do
  it 'should work with simple values' do
    'somekey=value'.should parse_as('somekey' => 'value')
  end
  
  it 'should work with hash values' do
    'somekey[somekey]=value'.should parse_as('somekey' => {'somekey' => 'value'})
  end
  
  def parse_as(expected)
    satisfy do |uri|
      actual = ActionController::AbstractRequest.parse_query_parameters(URI.escape(uri))
      actual == expected
    end
  end
end

describe 'Hash form extension' do
  it 'should work with simple values' do
    {:somekey => 'value'}.to_fields.should == {
      'somekey' => ['value']
    }
  end

  it 'should work with hash values' do
    {:somekey => {:somekey => 'value'}}.to_fields.should == {
      'somekey[somekey]' => ['value']
    }
  end
  
  it 'should work with arrays in hash values' do
    {:somekey => ['value']}.to_fields.should == {
      'somekey[]' => ['value']
    }
    {:somekey => {:somekey => ['value']}}.to_fields.should == {
      'somekey[somekey][]' => ['value']
    }
  end
  
  it 'should work with array of hashes' do
    {:somekey => [{:somekey => 'value'}, {:somekey => 'value2'}, {:otherkey => 'value3', :anotherkey => 1}]}.to_fields.should == {
      'somekey[][somekey]'  => ['value', 'value2'],
      'somekey[][otherkey]' => ['value3'],
      'somekey[][anotherkey]' => [1]
    }
  end
end