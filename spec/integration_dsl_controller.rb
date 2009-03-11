class IntegrationDslController < ApplicationController
  caches_action :caching_action
  
  def form
    render :text => %{<form action="/form" method="post"><input type='hidden' name='key' /></form>}
  end
  
  def exploding
    raise "This will blow up!"
  end
  
  def caching_action
    render :text => Time.now.to_s
  end
end