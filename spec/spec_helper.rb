SPEC_ROOT = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(SPEC_ROOT) # for application_controller.rb
 
RAILS_ROOT = File.expand_path("#{SPEC_ROOT}/..")
$LOAD_PATH.unshift("#{RAILS_ROOT}/lib")

require 'rubygems'
require 'active_support'
require 'active_record'
require 'action_pack'
require 'action_controller'
require 'action_mailer'

require 'rails/version'

require 'spec'
require 'spec/integration'
require 'integration_dsl_controller'

ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'integration_dsl' do |dsl|
    dsl.root
    dsl.connect '/caching_action', :action => 'caching_action'
    dsl.connect '/exploding',      :action => 'exploding'
    dsl.connect '/form',           :action => 'form'
  end
  map.connect '/caching/cache_store_params',
    :controller => 'caching', :action => 'cache_store_params'
end

