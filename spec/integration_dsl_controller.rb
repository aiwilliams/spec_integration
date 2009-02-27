class IntegrationDslController < ApplicationController
  def form
    render :text => %{<form action="/" method="post"><input type='hidden' name='key' /></form>}
  end
  
  def exploding
    raise "This will blow up!"
  end
end