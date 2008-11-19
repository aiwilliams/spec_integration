module Spec
  module Integration
    module DSL
      include Spec::Integration::Matchers
      include NavigationExampleMethods
      include FormExampleMethods
      
      include ActionController::RecordIdentifier
      
      class IntegrationExample < Spec::Rails::Example::RailsExampleGroup # :nodoc:
        include Spec::Integration::DSL
        include ActionController::Integration::Runner
        
        cattr_accessor :during_integration_example
        attr_reader :integration_session
        
        before :all do
          IntegrationExample::during_integration_example = true
        end
        
        after :all do
          IntegrationExample::during_integration_example = false
        end
        
        def method_missing(sym, *args, &block)
          return Spec::Matchers::Be.new(sym, *args) if sym.starts_with?("be_")
          return Spec::Matchers::Has.new(sym, *args) if sym.starts_with?("have_")
          super
        end
        
        Spec::Example::ExampleGroupFactory.register(:integration, self)
      end
      
    end
  end
end

# 97% copied from RubyRedRick's patch at
# http://dev.rubyonrails.org/attachment/ticket/11091/multi-part-integration.diff?format=raw
ActionController::Integration::Session.class_eval do
  class MultiPartNeededException < Exception # :nodoc:
  end
  
  def process_with_multipart_upload(method, path, parameters = nil, headers = nil)
    process_without_multipart_upload(method, path, parameters, headers)
  rescue MultiPartNeededException
    boundary = "----------XnJLe9ZIbbGUYtzPQJ16u1"
    status = process_without_multipart_upload(method, path, multipart_body(parameters, boundary), (headers || {}).merge({"CONTENT_TYPE" => "multipart/form-data; boundary=#{boundary}"}))
    return status
  end
  alias_method_chain :process, :multipart_upload
  
  def requestify_with_multipart_upload(parameters, prefix=nil)
    raise MultiPartNeededException if ::ActionController::TestUploadedFile === parameters
    requestify_without_multipart_upload(parameters, prefix)
  end
  alias_method_chain :requestify, :multipart_upload
  
  def multipart_requestify(params, first=true)
    returning p = {} do
      params.each do |key, value|
        k = first ? CGI.escape(key.to_s) : "[#{CGI.escape(key.to_s)}]"
        if Hash === value
          multipart_requestify(value, false).each do |subkey, subvalue|
            p[k + subkey] = subvalue
          end
        else
          p[k] = value
        end
      end
    end
  end

  def multipart_body(params, boundary)
    multipart_requestify(params).map do |key, value|
      if value.respond_to?(:original_filename)
        File.open(value.path) do |f|
          <<-EOF
--#{boundary}\r
Content-Disposition: form-data; name="#{key}"; filename="#{CGI.escape(value.original_filename)}"\r
Content-Type: #{value.content_type}\r
Content-Length: #{File.stat(value.path).size}\r
\r
#{f.read}\r
EOF
              end
            else
<<-EOF
--#{boundary}\r
Content-Disposition: form-data; name="#{key}"\r
\r
#{value}\r
EOF
      end
    end.join("")+"--#{boundary}--\r"
  end
end