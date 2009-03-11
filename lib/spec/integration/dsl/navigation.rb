module Spec
  module Integration
    module DSL

      # Uses css_select to retrieve the anchor having href_or_id. The
      # expects may indicate:
      #
      # Options are:
      #
      # * <tt>:count</tt> - An expression indicating the expected number of times the link can appear.
      #   The default is '>= 1'.
      def find_anchors(href_or_id, expects = {})
        expects = {:count => ">= 1"}.update(expects)
        expects[:count] = "== #{expects[:count]}" if expects[:count].is_a? Integer
        if href_or_id =~ /\// # couldn't be an id with a slash in it
          links = css_select "a[href=#{href_or_id}]"
          violated "Expected #{expects[:count]} links to #{href_or_id}" unless eval("#{links.size} #{expects[:count]}")
        else
          links = css_select "a##{href_or_id}"
          violated "Expected only one link having id #{href_or_id}. Recall that id's must be unique in a DOM." unless links.size == 1
        end
        links
      end
      
      # Clicks the link having either href or id equal to value of :link. If
      # you don't care whether the link is actually on the page, try using
      # _navigate_to_.
      #  
      # Options are:
      #
      # * <tt>:link</tt>     - href value or element id
      # * <tt>:expects</tt>  - {:count => <expression>}. See _find_anchors_.
      # * <tt>:method</tt>   - the preferred method to invoke, which assumes
      #   there is more than one link with the same href but different
      #   methods to invoke (like a show and delete link, which use the same
      #   href but have methods of GET and DELETE). Defaults to :get.
      #
      def click_on(options)
        response.should have_navigated_successfully
        
        options = {
          :link => nil,
          :expects => {:count => ">= 1"},
          :method => :get
        }.update(options)
        
        href = nil
        method = options.delete(:method)
        anchors = find_anchors(options.delete(:link), options.delete(:expects))
        if anchors.size == 1
          anchor = anchors.first
          if onclick = anchor["onclick"]
            if onclick =~ /setAttribute\('name', '_method'\)/
              onclick =~ /setAttribute\('value', '(get|put|delete|post)'\)/
              href = anchor["href"]
              method = $1
            else
              violated "There is some funky onclick on that link"
            end
          else
            href = anchor["href"]
          end
        else
          anchor = nil
          anchors.each do |a|
            onclick = a["onclick"]
            if method == :get
              anchor = a unless onclick
            elsif onclick
              if onclick =~ /setAttribute\('name', '_method'\)/
                onclick =~ /setAttribute\('value', '(get|put|delete|post)'\)/
                anchor = a if $1.to_s == method.to_s
              else
                violated "There is some funky onclick on that link: #{a["onclick"]}"
              end
            end
          end
          violated "No anchor found having method='#{method}'" if anchor.nil?
          href = anchor["href"]
        end
        navigate_to CGI.unescapeHTML(href), method, nil, options
      end
      
      # Performs _method_ on the specified path, ensuring that doing so was
      # successful. Will follow redirects.
      def navigate_to(path, method = :get, params = nil, options = {})
        headers = options[:headers] || {}
        self.send method, path, params || {}, headers
        follow_redirect! while response.redirect?
        response.should have_navigated_successfully(path)
      end
      
      # Submits params to path, using the specified method - :post by
      # default
      def submit_to(path, params = {}, method = :post, options = {})
        navigate_to path, method, params, options
      end

    end
  end
end