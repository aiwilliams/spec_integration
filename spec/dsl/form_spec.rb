require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "submit_form", :type => :integration do
  it 'should submit the form' do
    get '/form'
    submit_form :key => 'value'
    response.should_not be_nil
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
      <form action="/upload" id="upload_form" method="post" enctype="multipart/form-data">
        <input type="file" name="myfile[inhere]" />
      </form>
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
  
  it 'should use headers when provided' do
    should_receive(:post).with("/cancel", {}, {:authorization => 'stuff'})
    submit_form 'cancel_form', {}, :headers => {:authorization => 'stuff'}
  end
  
  it "should not disturb file field values" do
    test_file = ActionController::TestUploadedFile.new(
      File.dirname(__FILE__) + "/../spec.opts", "text/plain"
    )
    should_receive(:post).with("/upload", {"myfile" => {"inhere" => test_file}}, an_instance_of(Hash))
    submit_form "upload_form", :myfile => {:inhere => test_file}
  end
  
  it 'should handle values that have special characters' do
    response.stub!(:body).and_return %{
      <form action="/special" method="get">
        <input type="text" name="myfield" />
        <input type="text" name="mynumber" />
      </form>
    }
    should_receive(:get).with("/special", {'myfield' => "my;special\nstuff", 'mynumber' => '1'}, an_instance_of(Hash))
    submit_form :myfield => "my;special\nstuff", :mynumber => 1
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
    
    it 'should submit only the values from the override when field is an array' do
      @expected['deeply'] = {'not_overridden' => ['value1', 'value2'], 'overridden' => 'from_form'}
      @expected['overridden'] = 'from_form'
      submit_form :deeply => {:not_overridden => ['value1', 'value2']}
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
    simple_matcher(expected) do |uri|
      Rack::Utils.parse_nested_query(URI.escape(uri)) == expected
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