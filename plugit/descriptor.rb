require 'rubygems'
require 'plugit'

PLUGIT_ROOT = File.expand_path(File.dirname(__FILE__))

Plugit.describe do |dataset|
  dataset.environments_root_path = "#{PLUGIT_ROOT}/environments"
  vendor_directory               = "#{PLUGIT_ROOT}/../vendor/plugins"
  
  dataset.environment :default, 'Release versions of Rails and RSpec' do |env|
    env.library :rails, :export => "git clone git://github.com/rails/rails.git --depth 1" do |rails|
      rails.before_install { `git co v2.2.1` }
      rails.load_paths = %w{/activesupport/lib /activerecord/lib /actionpack/lib}
      rails.requires = %w{active_support active_record active_record/fixtures action_controller action_view}
    end
    env.library :rspec, :export => "git clone git://github.com/dchelimsky/rspec.git --depth 1" do |rspec|
      rspec.after_update { `git co 1.1.11 && mkdir -p #{vendor_directory} && ln -sF #{File.expand_path('.')} #{vendor_directory + '/rspec'}` }
      rspec.requires = %w{spec}
    end
    env.library :rspec_rails, :export => "git clone git://github.com/dchelimsky/rspec-rails.git --depth 1" do |rspec_rails|
      rspec_rails.after_update { `git co 1.1.11` }
      rspec_rails.requires = %w{spec/rails}
    end
  end
  
  dataset.environment :edge, 'Edge versions of Rails and RSpec' do |env|
    env.library :rails, :export => "git clone git://github.com/rails/rails.git --depth 1" do |rails|
      rails.before_install { `git pull` }
      rails.load_paths = %w{/activesupport/lib /activerecord/lib /actionpack/lib}
      rails.requires = %w{active_support active_record active_record/fixtures action_controller action_view}
    end
    env.library :rspec, :export => "git clone git://github.com/dchelimsky/rspec.git --depth 1" do |rspec|
      rspec.after_update { `git pull && mkdir -p #{vendor_directory} && ln -sF #{File.expand_path('.')} #{vendor_directory + '/rspec'}` }
      rspec.requires = %w{spec}
    end
    env.library :rspec_rails, :export => "git clone git://github.com/dchelimsky/rspec-rails.git --depth 1" do |rspec_rails|
      rspec_rails.after_update { `git pull` }
      rspec_rails.requires = %w{spec/rails}
    end
  end
end