require 'rubygems'
gem 'plugit'
require 'plugit'

$LOAD_PATH << File.expand_path("#{File.dirname(__FILE__)}/../lib")
$LOAD_PATH << File.expand_path(File.dirname(__FILE__))
RAILS_ROOT = File.expand_path("#{File.dirname(__FILE__)}/..")

Plugit.describe do |scenarios|
  scenarios.environments_root_path = File.dirname(__FILE__) + '/environments'
  vendor_directory = File.expand_path(File.dirname(__FILE__) + '/../vendor/plugins')
  
  scenarios.environment :default, 'Edge versions of Rails and RSpec' do |env|
    env.library :rails, :export => "git clone git://github.com/rails/rails.git --depth 1" do |rails|
      rails.before_install { `git pull` }
      rails.load_paths = %w{/activesupport/lib /activerecord/lib /actionpack/lib}
      rails.requires = %w{active_support active_record action_controller action_view}
    end
    env.library :rspec, :export => "git clone git://github.com/dchelimsky/rspec.git --depth 1" do |rspec|
      rspec.before_install { `git pull && mkdir -p #{vendor_directory} && ln -sF #{File.expand_path('.')} #{vendor_directory + '/rspec'}` }
      rspec.requires = %w{spec}
    end
    env.library :rspec_rails, :export => "git clone git://github.com/dchelimsky/rspec-rails.git --depth 1" do |rspec_rails|
      rspec_rails.before_install { `git pull` }
      rspec_rails.requires = %w{spec/rails}
    end
  end

  scenarios.environment :released, 'Released versions of Rails and RSpec' do |env|
    env.library :rails, :export => "git clone git://github.com/rails/rails.git" do |rails|
      rails.after_update { `git co v2.1.0_RC1` }
      rails.load_paths = %w{/activesupport/lib /activerecord/lib /actionpack/lib}
      rails.requires = %w{active_support active_record action_controller action_view}
    end
    env.library :rspec, :export => "git clone git://github.com/dchelimsky/rspec.git" do |rspec|
      rspec.after_update { `git co 1.1.4` }
      rspec.before_install { `mkdir -p #{vendor_directory} && ln -sF #{File.expand_path('.')} #{vendor_directory + '/rspec'}` }
      rspec.requires = %w{spec}
    end
    env.library :rspec_rails, :export => "git clone git://github.com/dchelimsky/rspec-rails.git" do |rspec_rails|
      rspec_rails.after_update { `git co 1.1.4` }
      rspec_rails.requires = %w{spec/rails}
    end
  end
end