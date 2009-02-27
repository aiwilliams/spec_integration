require File.dirname(__FILE__) + '/../spec_helper'

describe "submit_form", :type => :integration do
  it 'should submit the form' do
    with_routing do |set|
      set.draw do |map|
        map.connect '/', :controller => 'integration_dsl', :action => 'form'
        get '/'
        submit_form :key => 'value'
        response.should_not be_nil
      end
    end
  end
end

describe "submit_form", :type => :controller do
  include Spec::Integration::DSL
  include Spec::Integration::Matchers
  controller_name :integration_dsl
  
  before do
    response.stub!(:body).and_return %{
      <form action="/order" id="order_form" method="get"></form>
      <form action="/cancel" id="cancel_form" method="post"></form>
      <form action="/repeat" class="special" method="post"></form>
    }
  end
  
  it "should find the form having the given id" do
    should_receive(:post).with("/cancel", {}, an_instance_of(Hash))
    submit_form "cancel_form"
  end
  
  it 'should find the form matching the given css selector' do
    should_receive(:post).with("/repeat", {}, an_instance_of(Hash))
    submit_form '.special'
  end
  
  it 'should use single form without having to specify' do
    response.stub!(:body).and_return %{
      <form action="/single" method="get"></form>
    }
    should_receive(:get).with('/single', {}, an_instance_of(Hash))
    submit_form
  end
  
  it "should use method of the rendered form" do
    should_receive(:get).with("/order", {}, an_instance_of(Hash))
    submit_form "order_form"
  end
  
  describe 'hidden fields' do
    controller_name :integration_dsl
    
    before do
      response.stub!(:body).and_return %{
        <form action="/hiddens" method="post">
          <input type="hidden" name="_method" value="put" />
          <input type="hidden" name="not_overridden" value="from_form" />
          <input type="hidden" name="overridden" value="from_form" />
          <input type="hidden" name="deeply[overridden]" value="from_form" />
          <input type="hidden" name="deeply[not_overridden][]" value="from_form1" />
          <input type="hidden" name="deeply[not_overridden][]" value="from_form2" />
        </form>
      }
      @expected = {
        '_method' => 'put',
        'not_overridden' => 'from_form',
        'overridden' => 'not_from_form',
        'deeply' => {
          'not_overridden' => ['from_form1', 'from_form2'],
          'overridden' => 'not_from_form'
        }
      }
      should_receive(:post).with("/hiddens", @expected, an_instance_of(Hash))
    end
    
    it 'should be overridden when values are supplied' do
      submit_form :overridden => 'not_from_form', :deeply => {:overridden => 'not_from_form'}
    end
    
    it 'should remove in an array when overridden' do
      @expected['deeply'] = {'not_overridden' => ['value'], 'overridden' => 'from_form'}
      @expected['overridden'] = 'from_form'
      submit_form :deeply => {:not_overridden => ['value']}
    end
    
    it 'should exclude all but _method when :include_hidden is false' do
      @expected.delete('not_overridden')
      @expected['deeply'].delete('not_overridden')
      submit_form({:overridden => 'not_from_form', :deeply => {:overridden => 'not_from_form'}}, :include_hidden => false)
    end
  end
end

describe 'Expectations about parsing query parameters: ' do
  it 'should work with simple values' do
    'somekey=value'.should parse_as('somekey' => 'value')
  end
  
  it 'should work with hash values' do
    'somekey[somekey]=value'.should parse_as('somekey' => {'somekey' => 'value'})
  end
  
  # This one needs explaining. When you have an array of hashes, parameters should be
  # placed in the most recently created hash. A new hash is created when a key, like
  # 'one' in this test, re-occurs.
  it 'should correctly place additional attributes in the order found' do
    'level1[][one]=1&level1[][two]=2&level1[][one]=3&level1[][two]=4&level1[][three]=5'.should parse_as(
      {'level1' => [{'one' => '1', 'two' => '2'}, {'one' => '3', 'two' => '4', 'three' => '5'}]}
    )
  end
  
  def parse_as(expected)
    satisfy do |uri|
      actual = ActionController::UrlEncodedPairParser.parse_query_parameters(URI.escape(uri))
      actual == expected
    end
  end
end

describe 'Hash form extension' do
  it 'should work with simple values' do
    {:somekey => 'value'}.to_fields.should == [['somekey', 'value']]
  end

  it 'should work with hash values' do
    {:somekey => {:somekey => 'value'}}.to_fields.should == [['somekey[somekey]', 'value']]
  end
  
  it 'should work with arrays in hash values' do
    {:somekey => ['value']}.to_fields.should == [['somekey[]', 'value']]
    {:somekey => {:somekey => ['value']}}.to_fields.should == [['somekey[somekey][]', 'value']]
  end
  
  it 'should work with array of hashes' do
    fields = {:somekey => [{:somekey => 'value'}, {:somekey => 'value2'}, {:somekey => 'value4', :otherkey => 'value3', :anotherkey => 1}]}.to_fields
    fields.should include(['somekey[][somekey]', 'value'])
    fields.should include(['somekey[][somekey]', 'value2'])
    fields.should include(['somekey[][somekey]', 'value4'])
    fields.should include(['somekey[][otherkey]', 'value3'])
    fields.should include(['somekey[][anotherkey]', 1])
  end
end