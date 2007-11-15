module Spec
  module Integration
    module DSL

      module NavigationExampleMethods
        # Uses css_select to retrieve the anchor having href_or_id. The
        # expects may indicate:
        #
        # Options are:
        #   <tt>:count</tt> - An expression indicating the expected number of times the link can appear.
        #                     The default is '>= 1'.
        def find_anchor(href_or_id, expects = {})
          expects = {:count => ">= 1"}.update(expects)
          expects[:count] = "== #{expects[:count]}" if expects[:count].is_a? Integer
          if href_or_id =~ /\// # couldn't be an id with a slash in it
            links = css_select "a[href=#{href_or_id}]"
            violated "Expected #{expects[:count]} links to #{href_or_id}" unless eval("#{links.size} #{expects[:count]}")
          else
            links = css_select "a##{href_or_id}"
            violated "Expected only one link having id #{href_or_id}. Recall that id's must be unique in a DOM." unless links.size == 1
          end
          links[0]
        end
        
        # Clicks the link having either href or id equal to value of :link. If
        # you don't care whether the link is actually on the page, try using
        # _navigate_to_.
        #  
        # Options are:
        #   <tt>:link</tt>     - href value or element id
        #   <tt>:expects</tt>  - {:count => <expression>}. See _find_anchor_.
        def click_on(options)
          should have_navigated_successfully
          options = {
            :link => nil,
            :expects => {:count => ">= 1"}
          }.update(options)

          anchor = find_anchor(options[:link], options[:expects])
          if onclick = anchor["onclick"]
            if onclick =~ /setAttribute\('name', '_method'\)/
              onclick =~ /setAttribute\('value', '(get|put|delete|post)'\)/
              navigate_to anchor["href"], $1
            else
              violated "There is some funky onclick on that link"
            end
          else
            navigate_to anchor["href"]
          end
        end
        
        # Performs _method_ on the specified path, ensuring that doing so was
        # successful. Will follow redirects.
        def navigate_to(path, method = :get, params = nil)
          self.send method, path, params || {}
          follow_redirect! if response.redirect?
          should have_navigated_successfully(path)
        end
        
        # Submits params to path, using the specified method - :post by
        # default
        def submit_to(path, params = {}, method = :post)
          navigate_to path, method, params
        end
      end

    end
  end
end